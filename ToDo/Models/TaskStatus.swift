//
//  TaskStatus.swift
//  ToDo
//

import Foundation

/// The four workflow states. The order of the cases is the order of the Board columns.
nonisolated enum TaskStatus: String, CaseIterable, Identifiable, Sendable {
    case todo
    case inProgress
    case test
    case done

    var id: String { rawValue }

    var label: L10n {
        switch self {
        case .todo: .statusToDo
        case .inProgress: .statusInProgress
        case .test: .statusTest
        case .done: .statusDone
        }
    }
}

nonisolated enum TaskPriority: String, CaseIterable, Identifiable, Sendable {
    case high
    case medium
    case low

    var id: String { rawValue }

    var label: L10n {
        switch self {
        case .high: .priorityHigh
        case .medium: .priorityMedium
        case .low: .priorityLow
        }
    }
}

nonisolated enum SprintState: String, CaseIterable, Identifiable, Sendable {
    case planned
    case active
    case completed

    var id: String { rawValue }

    var label: L10n {
        switch self {
        case .planned: .sprintPlanned
        case .active: .sprintActive
        case .completed: .sprintCompleted
        }
    }
}
