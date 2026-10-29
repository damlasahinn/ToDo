//
//  TaskEditorViewModel.swift
//  ToDo
//
//  Holds an editable copy of a task. Nothing is written until the user presses
//  Create/Save, so Cancel discards changes.
//

import Foundation
import Observation

@Observable
final class TaskEditorViewModel {
    enum Mode {
        case create(sprint: Sprint?, status: TaskStatus)
        case edit(TaskItem)
    }

    let mode: Mode
    var title: String
    var details: String
    var status: TaskStatus
    var priority: TaskPriority?
    var sprint: Sprint?

    /// Copied at init so the sheet never reads a task that is being deleted.
    let taskKey: String?
    let createdAt: Date?
    let updatedAt: Date?

    init(mode: Mode) {
        self.mode = mode
        switch mode {
        case .create(let sprint, let status):
            title = ""
            details = ""
            self.status = status
            priority = nil
            self.sprint = sprint
            taskKey = nil
            createdAt = nil
            updatedAt = nil
        case .edit(let task):
            title = task.title
            details = task.details
            status = task.status
            priority = task.priority
            sprint = task.sprint
            taskKey = task.key
            createdAt = task.createdAt
            updatedAt = task.updatedAt
        }
    }

    var isEditing: Bool {
        if case .edit = mode { true } else { false }
    }

    var editedTask: TaskItem? {
        if case .edit(let task) = mode { task } else { nil }
    }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var canSave: Bool { !trimmedTitle.isEmpty }

    /// Sprints a task can be assigned to: active and planned ones, plus the task's current
    /// sprint when that one is already completed (so the picker can show it).
    func sprintOptions(from sprints: [Sprint]) -> [Sprint] {
        var options = ScopeViewModel.openSprintsInOrder(sprints)
        if let sprint, !sprint.isOpen {
            options.append(sprint)
        }
        return options
    }

    func save(using store: ProjectStore) {
        guard canSave else { return }
        let details = details.trimmingCharacters(in: .whitespacesAndNewlines)
        switch mode {
        case .create:
            store.createTask(title: trimmedTitle, details: details, status: status, priority: priority, sprint: sprint)
        case .edit(let task):
            store.update(task, title: trimmedTitle, details: details, status: status, priority: priority, sprint: sprint)
        }
    }
}
