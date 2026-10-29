//
//  CompleteSprintViewModel.swift
//  ToDo
//

import Foundation
import Observation

@Observable
final class CompleteSprintViewModel {
    let sprint: Sprint
    let doneCount: Int
    let openCount: Int
    /// By default everything stays in the completed sprint, preserving its final state.
    var destination: OpenTaskDestination = .keepInSprint

    init(sprint: Sprint) {
        self.sprint = sprint
        doneCount = sprint.tasks.filter(\.isDone).count
        openCount = sprint.tasks.count - doneCount
    }

    /// Planned sprints that open tasks can be carried over to.
    func plannedSprints(from sprints: [Sprint]) -> [Sprint] {
        ScopeViewModel.openSprintsInOrder(sprints).filter { $0.state == .planned }
    }

    func complete(using store: ProjectStore) {
        store.complete(sprint, movingOpenTasksTo: openCount > 0 ? destination : .keepInSprint)
    }
}
