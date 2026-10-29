//
//  KanbanColumn.swift
//  ToDo
//
//  One Board column. Dropping a card anywhere on the column moves it to this status;
//  dropping it on a card places it right above that card.
//

import SwiftUI

struct KanbanColumn: View {
    let status: TaskStatus
    let tasks: [TaskItem]
    let moveTargets: [Sprint]
    /// The first column always shows "Create task"; the others show it on hover.
    let alwaysShowsCreateButton: Bool
    let onDrop: (_ taskID: UUID, _ before: TaskItem?) -> Bool
    let onCreate: (String) -> Void

    @Environment(\.localizer) private var t
    @State private var isDropTargeted = false
    @State private var isHovered = false
    @State private var isCreating = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            ScrollView(.vertical) {
                VStack(spacing: 8) {
                    ForEach(tasks, id: \.uuid) { task in
                        TaskCard(task: task, moveTargets: moveTargets) { id in
                            onDrop(id, task)
                        }
                    }
                    InlineTaskCreator(isEditing: $isCreating, onCreate: onCreate)
                        .opacity(showsCreateButton ? 1 : 0)
                        .allowsHitTesting(showsCreateButton)
                }
                .padding(.horizontal, 8)
                .padding(.top, 2)
                .padding(.bottom, 8)
            }
            .scrollIndicators(.automatic)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(isDropTargeted ? Theme.dropHighlight : Theme.sunken, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay {
            if isDropTargeted {
                RoundedRectangle(cornerRadius: 10, style: .continuous).strokeBorder(Theme.brand, lineWidth: 2)
            }
        }
        .onHover { isHovered = $0 }
        .taskDropTarget(isTargeted: $isDropTargeted) { id in
            onDrop(id, nil)
        }
        .animation(.easeOut(duration: 0.12), value: isDropTargeted)
    }

    private var showsCreateButton: Bool {
        alwaysShowsCreateButton || isHovered || isCreating
    }

    private var header: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Theme.accent(status))
                .frame(width: 8, height: 8)
            Text(t.uppercased(status.label))
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Theme.textSubtle)
                .lineLimit(1)
            Text("\(tasks.count)")
                .font(.system(size: 12, weight: .semibold).monospacedDigit())
                .foregroundStyle(Theme.textSubtlest)
            if status == .done {
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Theme.accent(.done))
            }
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
    }
}
