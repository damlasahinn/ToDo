//
//  TaskDragPayload.swift
//  ToDo
//
//  Drag and drop carries a plain string that identifies the task. A string works with
//  SwiftUI's built-in Transferable support and needs no custom type declaration in
//  Info.plist. The prefix makes sure text dragged in from other apps is ignored.
//

import SwiftUI

nonisolated enum TaskDragPayload {
    private static let prefix = "todo-task:"

    static func make(for id: UUID) -> String {
        prefix + id.uuidString
    }

    static func taskID(from items: [String]) -> UUID? {
        guard let item = items.first, item.hasPrefix(prefix) else { return nil }
        return UUID(uuidString: String(item.dropFirst(prefix.count)))
    }
}

extension View {
    /// Makes the view draggable as a task, with a compact card as the drag preview.
    func taskDragSource(_ task: TaskItem) -> some View {
        draggable(TaskDragPayload.make(for: task.uuid)) {
            TaskDragPreview(task: task)
        }
    }

    /// Accepts dropped tasks. `perform` receives the task's id and returns whether the drop was handled.
    func taskDropTarget(
        isEnabled: Bool = true,
        isTargeted: Binding<Bool>,
        perform: @escaping (UUID) -> Bool
    ) -> some View {
        modifier(TaskDropModifier(isEnabled: isEnabled, isTargeted: isTargeted, perform: perform))
    }
}

private struct TaskDropModifier: ViewModifier {
    let isEnabled: Bool
    @Binding var isTargeted: Bool
    let perform: (UUID) -> Bool

    func body(content: Content) -> some View {
        if isEnabled {
            content.dropDestination(for: String.self) { items, _ in
                guard let id = TaskDragPayload.taskID(from: items) else { return false }
                return perform(id)
            } isTargeted: { targeted in
                isTargeted = targeted
            }
        } else {
            content
        }
    }
}
