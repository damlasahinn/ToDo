//
//  ScopeViewModel.swift
//  ToDo
//
//  Groups the queried sprints and tasks into the sections of the Scope screen and keeps
//  track of which sections are expanded.
//

import Foundation
import Observation
import SwiftUI

struct SprintGroup: Identifiable {
    let sprint: Sprint
    /// Tasks matching the search, in display order.
    let tasks: [TaskItem]
    /// All tasks of the sprint, used for the status counters.
    let allTasks: [TaskItem]

    var id: UUID { sprint.uuid }
}

struct ScopeContent {
    var openSprints: [SprintGroup] = []
    var completedSprints: [SprintGroup] = []
    var backlogTasks: [TaskItem] = []
    var allBacklogTasks: [TaskItem] = []
    var hasActiveSprint = false
    var isSearching = false
    var matchCount = 0

    /// Targets for "Move To" menus: active and planned sprints.
    var moveTargets: [Sprint] { openSprints.map(\.sprint) }
}

@Observable
final class ScopeViewModel {
    /// Sections whose expansion differs from their default
    /// (open sprints and the Backlog start expanded, completed sprints collapsed).
    private var toggledSections: Set<String> = []

    static let backlogSectionID = "backlog"
    static let completedGroupID = "completed"

    func isExpanded(_ id: String, defaultValue: Bool) -> Binding<Bool> {
        Binding(
            get: { self.toggledSections.contains(id) ? !defaultValue : defaultValue },
            set: { newValue in
                if newValue == defaultValue {
                    self.toggledSections.remove(id)
                } else {
                    self.toggledSections.insert(id)
                }
            }
        )
    }

    static func makeContent(sprints: [Sprint], tasks: [TaskItem], query: String) -> ScopeContent {
        var content = ScopeContent()
        content.isSearching = !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        content.hasActiveSprint = sprints.contains { $0.state == .active }

        let tasksBySprint = Dictionary(grouping: tasks) { $0.sprint?.uuid }
        func group(for sprint: Sprint) -> SprintGroup {
            let all = tasksBySprint[sprint.uuid] ?? []
            return SprintGroup(sprint: sprint, tasks: all.filter { $0.matches(query) }, allTasks: all)
        }

        content.openSprints = openSprintsInOrder(sprints).map(group(for:))
        content.completedSprints = sprints
            .filter { $0.state == .completed }
            .sorted { ($0.completedAt ?? $0.endDate) > ($1.completedAt ?? $1.endDate) }
            .map(group(for:))
        content.allBacklogTasks = tasksBySprint[nil] ?? []
        content.backlogTasks = content.allBacklogTasks.filter { $0.matches(query) }
        content.matchCount = tasks.filter { $0.matches(query) }.count
        return content
    }

    /// The active sprint first, then planned sprints by start date.
    static func openSprintsInOrder(_ sprints: [Sprint]) -> [Sprint] {
        sprints
            .filter(\.isOpen)
            .sorted { lhs, rhs in
                if lhs.state != rhs.state { return lhs.state == .active }
                if lhs.startDate != rhs.startDate { return lhs.startDate < rhs.startDate }
                return lhs.createdAt < rhs.createdAt
            }
    }
}
