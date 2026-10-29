//
//  SprintEditorViewModel.swift
//  ToDo
//
//  Backs the Create, Edit and Start Sprint sheets.
//

import Foundation
import Observation

nonisolated enum SprintDuration: Int, CaseIterable, Identifiable, Sendable {
    case oneWeek = 1
    case twoWeeks = 2
    case threeWeeks = 3
    case fourWeeks = 4
    case custom = 0

    var id: Int { rawValue }

    var label: L10n {
        self == .custom ? .durationCustom : .durationWeeks(rawValue)
    }
}

@Observable
final class SprintEditorViewModel {
    enum Mode {
        case create(SprintDraft)
        case edit(Sprint)
        case start(Sprint)
    }

    let mode: Mode
    var name: String
    var goal: String
    private(set) var startDate: Date
    private(set) var endDate: Date
    private(set) var duration: SprintDuration
    /// Number of tasks in the sprint, shown in the Start Sprint sheet.
    let taskCount: Int

    init(mode: Mode) {
        self.mode = mode
        let draft: SprintDraft
        switch mode {
        case .create(let suggestion):
            draft = suggestion
            taskCount = 0
        case .edit(let sprint):
            draft = SprintDraft(name: sprint.name, goal: sprint.goal, startDate: sprint.startDate, endDate: sprint.endDate)
            taskCount = sprint.tasks.count
        case .start(let sprint):
            draft = Self.startDraft(for: sprint)
            taskCount = sprint.tasks.count
        }
        name = draft.name
        goal = draft.goal
        startDate = draft.startDate
        endDate = draft.endDate
        duration = Self.duration(from: draft.startDate, to: draft.endDate)
    }

    var isStarting: Bool {
        if case .start = mode { true } else { false }
    }

    var isCreating: Bool {
        if case .create = mode { true } else { false }
    }

    var isDateRangeValid: Bool { endDate >= startDate }

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && isDateRangeValid
    }

    // MARK: Dates

    /// Changing the start date keeps the chosen duration.
    func setStartDate(_ date: Date) {
        startDate = date
        if duration != .custom {
            endDate = Self.endDate(from: date, weeks: duration.rawValue)
        } else if endDate < date {
            endDate = date
        }
    }

    /// Picking an end date by hand switches the duration to "Custom" unless it matches a preset.
    func setEndDate(_ date: Date) {
        endDate = date
        duration = Self.duration(from: startDate, to: date)
    }

    func setDuration(_ newValue: SprintDuration) {
        duration = newValue
        if newValue != .custom {
            endDate = Self.endDate(from: startDate, weeks: newValue.rawValue)
        }
    }

    // MARK: Saving

    func save(using store: ProjectStore) {
        guard canSave else { return }
        let draft = SprintDraft(name: name, goal: goal, startDate: startDate, endDate: endDate)
        switch mode {
        case .create:
            store.createSprint(draft)
        case .edit(let sprint):
            store.update(sprint, with: draft)
        case .start(let sprint):
            store.start(sprint, with: draft)
        }
    }

    // MARK: Helpers

    private static func endDate(from start: Date, weeks: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: weeks * 7, to: start) ?? start
    }

    private static func duration(from start: Date, to end: Date) -> SprintDuration {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: start), to: calendar.startOfDay(for: end)).day ?? 0
        return SprintDuration.allCases.first { $0 != .custom && $0.rawValue * 7 == days } ?? .custom
    }

    /// Keeps the planned dates, unless the sprint would already be over; then it restarts
    /// today with the same length.
    private static func startDraft(for sprint: Sprint) -> SprintDraft {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        guard sprint.endDate < today else {
            return SprintDraft(name: sprint.name, goal: sprint.goal, startDate: sprint.startDate, endDate: sprint.endDate)
        }
        let length = calendar.dateComponents([.day], from: sprint.startDate, to: sprint.endDate).day ?? 14
        let end = calendar.date(byAdding: .day, value: max(length, 1), to: today) ?? today
        return SprintDraft(name: sprint.name, goal: sprint.goal, startDate: today, endDate: end)
    }
}
