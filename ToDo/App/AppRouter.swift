//
//  AppRouter.swift
//  ToDo
//
//  Navigation and presentation state shared by the window, its views and the menu bar.
//

import Foundation
import Observation

enum SidebarItem: String, CaseIterable, Identifiable, Hashable {
    case scope
    case board
    case settings

    var id: String { rawValue }

    var label: L10n {
        switch self {
        case .scope: .scope
        case .board: .board
        case .settings: .settings
        }
    }

    var systemImage: String {
        switch self {
        case .scope: "list.bullet.rectangle"
        case .board: "rectangle.split.3x1"
        case .settings: "gearshape"
        }
    }
}

/// A sheet to present. The id is generated once, so presenting never reads model
/// properties (which matters after a model has been deleted).
struct SheetRoute: Identifiable {
    enum Kind {
        case createTask(sprint: Sprint?, status: TaskStatus)
        case editTask(TaskItem)
        case createSprint
        case editSprint(Sprint)
        case startSprint(Sprint)
        case completeSprint(Sprint)
    }

    let id = UUID()
    let kind: Kind
}

/// Values are copied when the confirmation is requested, so the alert never touches
/// a model after it has been deleted.
struct TaskDeletionRequest {
    let task: TaskItem
    let key: String
}

struct SprintDeletionRequest {
    let sprint: Sprint
    let name: String
    let taskCount: Int
}

@Observable
final class AppRouter {
    var selection: SidebarItem = .scope
    var sheet: SheetRoute?
    var searchText = ""
    var taskDeletion: TaskDeletionRequest?
    var sprintDeletion: SprintDeletionRequest?

    func present(_ kind: SheetRoute.Kind) {
        sheet = SheetRoute(kind: kind)
    }

    /// ⌘N: on the Board a new task goes into the active sprint, everywhere else into the Backlog.
    func presentNewTask(activeSprint: Sprint?) {
        guard sheet == nil else { return }
        present(.createTask(sprint: selection == .board ? activeSprint : nil, status: .todo))
    }

    func presentNewSprint() {
        guard sheet == nil else { return }
        present(.createSprint)
    }

    func confirmDeletion(of task: TaskItem) {
        taskDeletion = TaskDeletionRequest(task: task, key: task.key)
    }

    func confirmDeletion(of sprint: Sprint) {
        sprintDeletion = SprintDeletionRequest(sprint: sprint, name: sprint.name, taskCount: sprint.tasks.count)
    }
}
