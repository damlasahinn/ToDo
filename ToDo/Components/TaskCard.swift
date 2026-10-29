//
//  TaskCard.swift
//  ToDo
//
//  A Board card: title on top, then the task key and priority.
//  Dropping another card on it inserts that card right above.
//

import SwiftUI

struct TaskCard: View {
    let task: TaskItem
    let moveTargets: [Sprint]
    let onDropBefore: (UUID) -> Bool

    @Environment(AppRouter.self) private var router
    @State private var isHovered = false
    @State private var isDropTargeted = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(task.title)
                .font(.system(size: 13))
                .foregroundStyle(Theme.text)
                .lineLimit(4)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: 6) {
                TaskTypeIcon()
                TaskKeyLabel(task: task)
                Spacer(minLength: 4)
                if !task.details.isEmpty {
                    Image(systemName: "text.alignleft")
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.textSubtlest)
                        .accessibilityHidden(true)
                }
                PriorityIcon(priority: task.priority)
            }
        }
        .padding(12)
        .background(isHovered ? Theme.raisedHovered : Theme.raised, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).strokeBorder(Theme.border))
        .shadow(color: .black.opacity(0.18), radius: 1, y: 1)
        .overlay(alignment: .top) {
            if isDropTargeted {
                Capsule().fill(Theme.brand).frame(height: 3).offset(y: -6)
            }
        }
        .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .onHover { isHovered = $0 }
        .onTapGesture { router.present(.editTask(task)) }
        .taskDragSource(task)
        .taskDropTarget(isTargeted: $isDropTargeted, perform: onDropBefore)
        .contextMenu { TaskContextMenu(task: task, moveTargets: moveTargets) }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }
}

#if DEBUG
#Preview("Task card") {
    let task = PreviewEnvironment.store.activeSprint()?.tasks.first
    return VStack {
        if let task {
            TaskCard(task: task, moveTargets: [], onDropBefore: { _ in false })
        }
    }
    .frame(width: 280)
    .padding()
    .background(Theme.sunken)
    .previewEnvironment()
}
#endif
