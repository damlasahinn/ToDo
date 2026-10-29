//
//  BoardView.swift
//  ToDo
//
//  Kanban board for the active sprint: To Do, In Progress, Test, Done.
//

import SwiftData
import SwiftUI

struct BoardView: View {
    @Query(sort: \Sprint.createdAt) private var sprints: [Sprint]
    @Query(sort: TaskItem.displayOrder, animation: .snappy) private var tasks: [TaskItem]
    @Environment(ProjectStore.self) private var store
    @Environment(AppRouter.self) private var router
    @Environment(\.localizer) private var t

    private var activeSprint: Sprint? {
        sprints.first { $0.state == .active }
    }

    var body: some View {
        @Bindable var router = router
        Group {
            if let sprint = activeSprint {
                board(BoardViewModel(sprint: sprint, tasks: tasks, query: router.searchText))
            } else {
                noActiveSprint
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.surface)
        .navigationTitle(t(.board))
        .hidesToolbarTitle()
        .searchable(text: $router.searchText, placement: .toolbar, prompt: Text(t(.searchTasks)))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    router.presentNewTask(activeSprint: activeSprint)
                } label: {
                    Label(t(.createTask), systemImage: "plus")
                }
                .help(t(.createTaskHelp))
            }
        }
    }

    private func board(_ viewModel: BoardViewModel) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            BoardHeader(viewModel: viewModel)
            GeometryReader { proxy in
                let spacing: CGFloat = 12
                let fittingWidth = (proxy.size.width - spacing * 3) / 4
                let columnWidth = max(240, fittingWidth)
                ScrollView(.horizontal) {
                    HStack(alignment: .top, spacing: spacing) {
                        ForEach(viewModel.columns) { column in
                            KanbanColumn(
                                status: column.status,
                                tasks: column.tasks,
                                moveTargets: ScopeViewModel.openSprintsInOrder(sprints),
                                alwaysShowsCreateButton: column.status == .todo,
                                onDrop: { id, target in drop(id, on: column.status, before: target) },
                                onCreate: { title in
                                    store.createTask(title: title, status: column.status, sprint: viewModel.sprint)
                                }
                            )
                            .frame(width: columnWidth, height: proxy.size.height)
                        }
                    }
                }
                .scrollIndicators(fittingWidth >= 240 ? .hidden : .automatic)
            }
        }
        .padding(.horizontal, 28)
        .padding(.top, 24)
        .padding(.bottom, 20)
    }

    private var noActiveSprint: some View {
        let nextSprint = ScopeViewModel.openSprintsInOrder(sprints).first { $0.state == .planned }
        return ContentUnavailableView {
            Label(t(.noActiveSprintTitle), systemImage: "rectangle.split.3x1")
        } description: {
            Text(t(.noActiveSprintMessage))
        } actions: {
            HStack(spacing: 10) {
                Button(t(.goToScope)) { router.selection = .scope }
                    .buttonStyle(.neutralAction)
                if let nextSprint {
                    Button(t(.startNamedSprint(nextSprint.name))) { router.present(.startSprint(nextSprint)) }
                        .buttonStyle(.primaryAction)
                }
            }
        }
    }

    private func drop(_ id: UUID, on status: TaskStatus, before target: TaskItem?) -> Bool {
        guard let task = store.task(withID: id), let sprint = activeSprint else { return false }
        withAnimation(.snappy) {
            if task.sprint?.uuid != sprint.uuid {
                // A task dragged in from elsewhere joins the active sprint first.
                store.move(task, to: sprint)
            }
            store.moveOnBoard(task, to: status, before: target)
        }
        return true
    }
}

/// Sprint name, dates, time left, goal, progress and the Complete Sprint button.
private struct BoardHeader: View {
    let viewModel: BoardViewModel
    @Environment(AppRouter.self) private var router
    @Environment(\.localizer) private var t

    var body: some View {
        let sprint = viewModel.sprint
        HStack(alignment: .bottom, spacing: 24) {
            VStack(alignment: .leading, spacing: 6) {
                Text(t(.board))
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.textSubtlest)
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text(sprint.name)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(Theme.text)
                    SprintStateBadge(state: sprint.state)
                }
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                    Text(DateFormatting.range(from: sprint.startDate, to: sprint.endDate, locale: t.locale))
                    Text("·")
                    Text(t(.daysRemaining(DateFormatting.daysFromToday(to: sprint.endDate))))
                }
                .font(.system(size: 13))
                .foregroundStyle(Theme.textSubtle)
                if !sprint.goal.isEmpty {
                    Label(sprint.goal, systemImage: "target")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.textSubtle)
                        .lineLimit(2)
                }
            }
            Spacer(minLength: 16)
            VStack(alignment: .trailing, spacing: 10) {
                HStack(spacing: 8) {
                    Button(t(.editSprint)) { router.present(.editSprint(sprint)) }
                        .buttonStyle(.subtleAction)
                    Button(t(.completeSprint)) { router.present(.completeSprint(sprint)) }
                        .buttonStyle(.neutralAction)
                }
                VStack(alignment: .trailing, spacing: 4) {
                    Capsule()
                        .fill(Theme.neutralHovered)
                        .frame(width: 200, height: 6)
                        .overlay(alignment: .leading) {
                            Capsule()
                                .fill(Theme.accent(.done))
                                .frame(width: 200 * viewModel.progress)
                        }
                        .accessibilityElement()
                        .accessibilityValue(t(.tasksDone(viewModel.doneCount, viewModel.totalCount)))
                    Text(t(.tasksDone(viewModel.doneCount, viewModel.totalCount)))
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.textSubtlest)
                }
            }
        }
    }
}

#if DEBUG
#Preview("Board") {
    NavigationStack {
        BoardView()
    }
    .previewEnvironment()
    .frame(width: 1200, height: 760)
}
#endif
