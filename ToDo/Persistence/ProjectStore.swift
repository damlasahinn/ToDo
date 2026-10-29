//
//  ProjectStore.swift
//  ToDo
//

import Foundation
import Observation
import SwiftData

/// Every change to tasks and sprints goes through this store, so the business rules
/// (one active sprint, task numbering, ordering) live in one place. Views read data
/// with `@Query` and call these methods to change it. Each method saves immediately.
@Observable
final class ProjectStore {
    @ObservationIgnored let context: ModelContext

    /// Set when a save fails; the root view presents it in an alert.
    var saveErrorMessage: String?

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Lookup

    func task(withID id: UUID) -> TaskItem? {
        var descriptor = FetchDescriptor<TaskItem>(predicate: #Predicate { $0.uuid == id })
        descriptor.fetchLimit = 1
        return (try? context.fetch(descriptor))?.first
    }

    func activeSprint() -> Sprint? {
        let active = SprintState.active.rawValue
        var descriptor = FetchDescriptor<Sprint>(predicate: #Predicate { $0.stateRawValue == active })
        descriptor.fetchLimit = 1
        return (try? context.fetch(descriptor))?.first
    }

    func allSprints() -> [Sprint] {
        (try? context.fetch(FetchDescriptor<Sprint>(sortBy: [SortDescriptor(\.createdAt)]))) ?? []
    }

    /// Tasks of a sprint, or of the Backlog when `sprint` is nil, in display order.
    func tasks(in sprint: Sprint?) -> [TaskItem] {
        allTasks().filter { $0.sprint?.uuid == sprint?.uuid }
    }

    private func allTasks() -> [TaskItem] {
        (try? context.fetch(FetchDescriptor<TaskItem>(sortBy: TaskItem.displayOrder))) ?? []
    }

    // MARK: - Tasks

    @discardableResult
    func createTask(
        title: String,
        details: String = "",
        status: TaskStatus = .todo,
        priority: TaskPriority? = nil,
        sprint: Sprint? = nil
    ) -> TaskItem {
        let task = TaskItem(
            number: nextTaskNumber(),
            title: title,
            details: details,
            status: status,
            priority: priority,
            rank: nextRank()
        )
        context.insert(task)
        task.sprint = sprint
        save()
        return task
    }

    func update(
        _ task: TaskItem,
        title: String,
        details: String,
        status: TaskStatus,
        priority: TaskPriority?,
        sprint: Sprint?
    ) {
        if task.sprint?.uuid != sprint?.uuid {
            task.rank = rank(before: nil, in: tasks(in: sprint))
            task.sprint = sprint
        }
        task.title = title
        task.details = details
        task.status = status
        task.priority = priority
        task.updatedAt = .now
        save()
    }

    func setStatus(_ status: TaskStatus, for task: TaskItem) {
        guard task.status != status else { return }
        task.status = status
        task.updatedAt = .now
        save()
    }

    func setPriority(_ priority: TaskPriority?, for task: TaskItem) {
        guard task.priority != priority else { return }
        task.priority = priority
        task.updatedAt = .now
        save()
    }

    func delete(_ task: TaskItem) {
        context.delete(task)
        save()
    }

    /// Moves a task to a sprint, or to the Backlog when `sprint` is nil. With a `target`,
    /// the task is placed right before it; otherwise it goes to the end of the list.
    /// Completed sprints don't accept new tasks.
    func move(_ task: TaskItem, to sprint: Sprint?, before target: TaskItem? = nil) {
        if let sprint, !sprint.isOpen { return }
        if target?.uuid == task.uuid { return }
        let siblings = tasks(in: sprint).filter { $0.uuid != task.uuid }
        task.rank = rank(before: target, in: siblings)
        task.sprint = sprint
        task.updatedAt = .now
        save()
    }

    /// Handles a drop on the Board. Dropping onto a card places the task before that card.
    /// Dropping onto an empty part of a column only changes the status, so the task slots
    /// in at its usual position (the same thing Jira does).
    func moveOnBoard(_ task: TaskItem, to status: TaskStatus, before target: TaskItem?) {
        if let target {
            guard target.uuid != task.uuid else { return }
            let siblings = tasks(in: task.sprint).filter { $0.status == status && $0.uuid != task.uuid }
            task.rank = rank(before: target, in: siblings)
        } else if task.status == status {
            return
        }
        task.status = status
        task.updatedAt = .now
        save()
    }

    // MARK: - Sprints

    /// Suggested values for a new sprint: the next number, starting the day after the
    /// latest open sprint ends (or today), two weeks long.
    func makeSprintDraft() -> SprintDraft {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let sprints = allSprints()
        var start = today
        if let latestEnd = sprints.filter(\.isOpen).map(\.endDate).max(),
           let dayAfter = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: latestEnd)),
           dayAfter > today {
            start = dayAfter
        }
        let end = calendar.date(byAdding: .day, value: 14, to: start) ?? start
        // "Sprint" is the same word in English and Turkish, so the default name needs no translation.
        return SprintDraft(name: "Sprint \(nextSprintNumber(in: sprints))", goal: "", startDate: start, endDate: end)
    }

    @discardableResult
    func createSprint(_ draft: SprintDraft) -> Sprint {
        let sprint = Sprint(
            number: nextSprintNumber(in: allSprints()),
            name: draft.name,
            goal: draft.goal,
            startDate: draft.startDate,
            endDate: draft.endDate
        )
        apply(draft, to: sprint)
        context.insert(sprint)
        save()
        return sprint
    }

    func update(_ sprint: Sprint, with draft: SprintDraft) {
        apply(draft, to: sprint)
        save()
    }

    /// Only one sprint can be active at a time.
    func canStart(_ sprint: Sprint) -> Bool {
        sprint.state == .planned && activeSprint() == nil
    }

    func start(_ sprint: Sprint, with draft: SprintDraft) {
        guard canStart(sprint) else { return }
        apply(draft, to: sprint)
        sprint.state = .active
        sprint.startedAt = .now
        save()
    }

    /// Marks the sprint completed. Done tasks always stay in the sprint for later review;
    /// open tasks stay too unless the user chose to carry them over.
    func complete(_ sprint: Sprint, movingOpenTasksTo destination: OpenTaskDestination) {
        guard sprint.state == .active else { return }
        let openTasks = tasks(in: sprint).filter { !$0.isDone }
        switch destination {
        case .keepInSprint:
            break
        case .backlog:
            relocate(openTasks, to: nil)
        case .sprint(let target) where target.isOpen && target.uuid != sprint.uuid:
            relocate(openTasks, to: target)
        case .sprint:
            break
        }
        sprint.state = .completed
        sprint.completedAt = .now
        save()
    }

    /// Deletes a planned sprint. Its tasks are moved to the end of the Backlog first.
    func delete(_ sprint: Sprint) {
        guard sprint.state == .planned else { return }
        relocate(tasks(in: sprint), to: nil)
        context.delete(sprint)
        save()
    }

    // MARK: - Saving

    func save() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            saveErrorMessage = error.localizedDescription
        }
    }

    // MARK: - Helpers

    private func apply(_ draft: SprintDraft, to sprint: Sprint) {
        let calendar = Calendar.current
        sprint.name = draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
        sprint.goal = draft.goal.trimmingCharacters(in: .whitespacesAndNewlines)
        sprint.startDate = calendar.startOfDay(for: draft.startDate)
        sprint.endDate = max(calendar.startOfDay(for: draft.endDate), sprint.startDate)
    }

    /// Appends tasks, in their current order, to the end of a sprint or the Backlog.
    private func relocate(_ tasks: [TaskItem], to sprint: Sprint?) {
        var rank = self.tasks(in: sprint).last?.rank ?? 0
        for task in tasks {
            rank += 1
            task.rank = rank
            task.sprint = sprint
            task.updatedAt = .now
        }
    }

    /// A rank that places a task before `target` within `siblings` (sorted by rank),
    /// or after the last sibling when there is no target.
    private func rank(before target: TaskItem?, in siblings: [TaskItem]) -> Double {
        guard let target, let index = siblings.firstIndex(where: { $0.uuid == target.uuid }) else {
            return (siblings.last?.rank ?? 0) + 1
        }
        let previous = index > 0 ? siblings[index - 1].rank : target.rank - 1
        if target.rank - previous < 0.000_001 {
            // Repeated inserts between the same neighbours ran out of precision.
            normalizeRanks()
            let renumbered = index > 0 ? siblings[index - 1].rank : target.rank - 1
            return (renumbered + target.rank) / 2
        }
        return (previous + target.rank) / 2
    }

    private func normalizeRanks() {
        for (index, task) in allTasks().enumerated() {
            task.rank = Double(index + 1)
        }
    }

    private func nextRank() -> Double {
        var descriptor = FetchDescriptor<TaskItem>(sortBy: [SortDescriptor(\.rank, order: .reverse)])
        descriptor.fetchLimit = 1
        return ((try? context.fetch(descriptor))?.first?.rank ?? 0) + 1
    }

    private func nextTaskNumber() -> Int {
        let sequence = identifierSequence(named: "task")
        var descriptor = FetchDescriptor<TaskItem>(sortBy: [SortDescriptor(\.number, order: .reverse)])
        descriptor.fetchLimit = 1
        let highest = (try? context.fetch(descriptor))?.first?.number ?? 0
        let number = max(sequence.nextValue, highest + 1)
        sequence.nextValue = number + 1
        return number
    }

    private func nextSprintNumber(in sprints: [Sprint]) -> Int {
        (sprints.map(\.number).max() ?? 0) + 1
    }

    private func identifierSequence(named name: String) -> IdentifierSequence {
        var descriptor = FetchDescriptor<IdentifierSequence>(predicate: #Predicate { $0.name == name })
        descriptor.fetchLimit = 1
        if let existing = (try? context.fetch(descriptor))?.first {
            return existing
        }
        let sequence = IdentifierSequence(name: name, nextValue: 1)
        context.insert(sequence)
        return sequence
    }
}
