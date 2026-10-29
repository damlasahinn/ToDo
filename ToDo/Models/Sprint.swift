//
//  Sprint.swift
//  ToDo
//

import Foundation
import SwiftData

@Model
final class Sprint {
    var uuid: UUID = UUID()
    /// Sequence number used for the suggested name of the next sprint ("Sprint 3").
    var number: Int = 0
    var name: String = ""
    var goal: String = ""
    var startDate: Date = Date.now
    var endDate: Date = Date.now
    var stateRawValue: String = SprintState.planned.rawValue
    var createdAt: Date = Date.now
    var startedAt: Date?
    var completedAt: Date?

    /// Deleting a sprint never deletes its tasks: they fall back to the Backlog.
    @Relationship(deleteRule: .nullify, inverse: \TaskItem.sprint)
    var tasks: [TaskItem] = []

    init(number: Int, name: String, goal: String, startDate: Date, endDate: Date) {
        self.number = number
        self.name = name
        self.goal = goal
        self.startDate = startDate
        self.endDate = endDate
        self.createdAt = .now
    }
}

extension Sprint {
    var state: SprintState {
        get { SprintState(rawValue: stateRawValue) ?? .planned }
        set { stateRawValue = newValue.rawValue }
    }

    /// Planned or active sprints can still receive tasks.
    var isOpen: Bool { state != .completed }
}

/// Editable values of a sprint, used by the sprint sheets before anything is saved.
struct SprintDraft {
    var name: String
    var goal: String
    var startDate: Date
    var endDate: Date
}

/// Where the unfinished tasks of a sprint go when it is completed.
enum OpenTaskDestination: Hashable {
    case keepInSprint
    case backlog
    case sprint(Sprint)
}
