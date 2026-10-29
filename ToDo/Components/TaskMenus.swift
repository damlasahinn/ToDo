//
//  TaskMenus.swift
//  ToDo
//

import SwiftUI

/// A status lozenge that opens a menu to change the status, like Jira's backlog rows.
struct TaskStatusMenu: View {
    let task: TaskItem
    @Environment(ProjectStore.self) private var store
    @Environment(\.localizer) private var t

    var body: some View {
        Menu {
            Picker(t(.status), selection: Binding(
                get: { task.status },
                set: { newValue in withAnimation(.snappy) { store.setStatus(newValue, for: task) } }
            )) {
                ForEach(TaskStatus.allCases) { status in
                    Text(t(status.label)).tag(status)
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()
        } label: {
            StatusLozenge(status: task.status, showsChevron: true)
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
        .fixedSize()
        .help(t(.changeStatus))
    }
}

/// Right-click menu shared by Scope rows and Board cards.
struct TaskContextMenu: View {
    let task: TaskItem
    /// Active and planned sprints the task can be moved to.
    let moveTargets: [Sprint]
    @Environment(ProjectStore.self) private var store
    @Environment(AppRouter.self) private var router
    @Environment(\.localizer) private var t

    var body: some View {
        Button(t(.editTaskEllipsis)) {
            router.present(.editTask(task))
        }

        Divider()

        Picker(t(.status), selection: Binding(
            get: { task.status },
            set: { newValue in withAnimation(.snappy) { store.setStatus(newValue, for: task) } }
        )) {
            ForEach(TaskStatus.allCases) { status in
                Text(t(status.label)).tag(status)
            }
        }

        Picker(t(.priority), selection: Binding(
            get: { task.priority },
            set: { store.setPriority($0, for: task) }
        )) {
            Text(t(.priorityNone)).tag(TaskPriority?.none)
            ForEach(TaskPriority.allCases) { priority in
                Text(t(priority.label)).tag(TaskPriority?.some(priority))
            }
        }

        let destinations = moveTargets.filter { $0.uuid != task.sprint?.uuid }
        Menu(t(.moveTo)) {
            if task.sprint != nil {
                Button(t(.backlog)) {
                    withAnimation(.snappy) { store.move(task, to: nil) }
                }
            }
            ForEach(destinations) { sprint in
                Button(sprint.name) {
                    withAnimation(.snappy) { store.move(task, to: sprint) }
                }
            }
        }
        .disabled(task.sprint == nil && destinations.isEmpty)

        Divider()

        Button(t(.deleteTaskEllipsis), role: .destructive) {
            router.confirmDeletion(of: task)
        }
    }
}
