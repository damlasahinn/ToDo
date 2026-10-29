//
//  TaskRow.swift
//  ToDo
//
//  One task in a Scope list: icon, key, title, priority and a status menu.
//  Click to edit, drag to move, right-click for more actions. Dropping another task on a
//  row inserts it right above that row.
//

import SwiftUI

struct TaskRow: View {
    let task: TaskItem
    let moveTargets: [Sprint]
    let acceptsDrops: Bool
    let onDropBefore: (UUID) -> Bool

    @Environment(AppRouter.self) private var router
    @State private var isHovered = false
    @State private var isDropTargeted = false

    var body: some View {
        HStack(spacing: 10) {
            TaskTypeIcon()
            TaskKeyLabel(task: task)
                .frame(minWidth: 58, alignment: .leading)
            Text(task.title)
                .font(.system(size: 13))
                .foregroundStyle(Theme.text)
                .lineLimit(1)
                .truncationMode(.tail)
            Spacer(minLength: 12)
            if !task.details.isEmpty {
                Image(systemName: "text.alignleft")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.textSubtlest)
                    .accessibilityHidden(true)
            }
            PriorityIcon(priority: task.priority)
            // Fixed-width column keeps priority icons aligned whatever the status label length.
            TaskStatusMenu(task: task)
                .frame(width: 124, alignment: .leading)
        }
        .padding(.horizontal, 12)
        .frame(minHeight: 40)
        .background(isHovered ? Theme.raisedHovered : Theme.raised)
        .overlay(alignment: .top) {
            if isDropTargeted {
                Rectangle().fill(Theme.brand).frame(height: 2)
            }
        }
        .contentShape(Rectangle())
        .onHover { isHovered = $0 }
        .onTapGesture { router.present(.editTask(task)) }
        .taskDragSource(task)
        .taskDropTarget(isEnabled: acceptsDrops, isTargeted: $isDropTargeted, perform: onDropBefore)
        .contextMenu { TaskContextMenu(task: task, moveTargets: moveTargets) }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }
}
