//
//  SprintSection.swift
//  ToDo
//
//  A collapsible block on the Scope screen, used for every sprint and for the Backlog.
//  The header shows name, dates, task count, per-status counters and the sprint actions.
//  Dropping a task on the section moves it to the end of that sprint (or the Backlog).
//

import SwiftUI

struct SprintSection: View {
    enum Kind {
        case sprint(Sprint)
        case backlog
    }

    let kind: Kind
    /// Tasks matching the search, in display order.
    let tasks: [TaskItem]
    /// All tasks in the section, used for counters.
    let allTasks: [TaskItem]
    let moveTargets: [Sprint]
    let canStartSprint: Bool
    let isSearching: Bool
    @Binding var isExpanded: Bool

    @Environment(ProjectStore.self) private var store
    @Environment(AppRouter.self) private var router
    @Environment(\.localizer) private var t
    @State private var isDropTargeted = false
    @State private var isCreating = false

    private var sprint: Sprint? {
        if case .sprint(let sprint) = kind { sprint } else { nil }
    }

    /// Completed sprints are kept for review and don't accept new tasks.
    private var acceptsTasks: Bool { sprint?.isOpen ?? true }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            header
            if isExpanded {
                content
                    .transition(.opacity)
            }
        }
        .padding(12)
        .background(isDropTargeted ? Theme.dropHighlight : Theme.sunken, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay {
            if isDropTargeted {
                RoundedRectangle(cornerRadius: 10, style: .continuous).strokeBorder(Theme.brand, lineWidth: 2)
            }
        }
        .taskDropTarget(isEnabled: acceptsTasks, isTargeted: $isDropTargeted) { id in
            drop(id, before: nil)
        }
        .animation(.easeOut(duration: 0.12), value: isDropTargeted)
    }

    // MARK: Header

    private var header: some View {
        HStack(spacing: 10) {
            Button {
                withAnimation(.snappy) { isExpanded.toggle() }
            } label: {
                titleLabel
            }
            .buttonStyle(.plain)
            .help(isExpanded ? t(.collapse) : t(.expand))

            Spacer(minLength: 12)

            StatusCountPills(tasks: allTasks)
            actions
        }
        .contextMenu { sprintMenuItems }
    }

    private var titleLabel: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Theme.textSubtle)
                .rotationEffect(.degrees(isExpanded ? 90 : 0))
                .frame(width: 14)
            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(sprint?.name ?? t(.backlog))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.text)
                    if let sprint {
                        Text(DateFormatting.range(from: sprint.startDate, to: sprint.endDate, locale: t.locale))
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.textSubtle)
                    }
                    Text("(\(countText))")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.textSubtlest)
                    if let sprint, sprint.state != .planned {
                        SprintStateBadge(state: sprint.state)
                    }
                }
                if let goal = sprint?.goal, !goal.isEmpty {
                    Text(goal)
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.textSubtle)
                        .lineLimit(2)
                }
            }
        }
        .contentShape(Rectangle())
    }

    private var countText: String {
        isSearching ? t(.filteredTaskCount(tasks.count, allTasks.count)) : t(.taskCount(allTasks.count))
    }

    @ViewBuilder
    private var actions: some View {
        switch kind {
        case .backlog:
            Button(t(.createSprint)) { router.presentNewSprint() }
                .buttonStyle(.neutralAction)
        case .sprint(let sprint):
            switch sprint.state {
            case .planned:
                Button(t(.startSprint)) { router.present(.startSprint(sprint)) }
                    .buttonStyle(.neutralAction)
                    .disabled(!canStartSprint)
                    .help(canStartSprint ? t(.startSprintHelp) : t(.anotherSprintActive))
            case .active:
                Button(t(.completeSprint)) { router.present(.completeSprint(sprint)) }
                    .buttonStyle(.neutralAction)
            case .completed:
                if let completedAt = sprint.completedAt {
                    Text(t(.completedOn(DateFormatting.medium(completedAt, locale: t.locale))))
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.textSubtle)
                }
            }
            Menu {
                sprintMenuItems
            } label: {
                Image(systemName: "ellipsis")
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .fixedSize()
            .help(t(.moreActions))
        }
    }

    @ViewBuilder
    private var sprintMenuItems: some View {
        if let sprint {
            Button(t(.editSprintEllipsis)) { router.present(.editSprint(sprint)) }
            switch sprint.state {
            case .planned:
                Button(t(.startSprint)) { router.present(.startSprint(sprint)) }
                    .disabled(!canStartSprint)
                Divider()
                Button(t(.deleteSprintEllipsis), role: .destructive) { router.confirmDeletion(of: sprint) }
            case .active:
                Button(t(.completeSprint)) { router.present(.completeSprint(sprint)) }
            case .completed:
                EmptyView()
            }
        } else {
            Button(t(.createSprint)) { router.presentNewSprint() }
        }
    }

    // MARK: Content

    @ViewBuilder
    private var content: some View {
        if tasks.isEmpty {
            emptyState
        } else {
            VStack(spacing: 0) {
                ForEach(Array(tasks.enumerated()), id: \.element.uuid) { index, task in
                    if index > 0 {
                        Rectangle().fill(Theme.border).frame(height: 1)
                    }
                    TaskRow(task: task, moveTargets: moveTargets, acceptsDrops: acceptsTasks) { id in
                        drop(id, before: task)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 6, style: .continuous).strokeBorder(Theme.border))
        }
        if acceptsTasks {
            InlineTaskCreator(isEditing: $isCreating) { title in
                store.createTask(title: title, sprint: sprint)
            }
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        if isSearching && !allTasks.isEmpty {
            EmptyDropZone(title: nil, message: t(.noMatchingTasks))
        } else if let sprint, !sprint.isOpen {
            EmptyDropZone(title: nil, message: t(.completedSprintEmpty))
        } else if sprint != nil {
            EmptyDropZone(title: t(.emptySprintTitle), message: t(.emptySprintMessage))
        } else {
            EmptyDropZone(title: nil, message: t(.emptyBacklog))
        }
    }

    private func drop(_ id: UUID, before target: TaskItem?) -> Bool {
        guard acceptsTasks, let task = store.task(withID: id) else { return false }
        withAnimation(.snappy) {
            store.move(task, to: sprint, before: target)
        }
        return true
    }
}
