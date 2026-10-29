//
//  ScopeView.swift
//  ToDo
//
//  Sprint planning: the active sprint, planned sprints, the Backlog and, at the bottom,
//  completed sprints kept for review.
//

import SwiftData
import SwiftUI

struct ScopeView: View {
    @Query(sort: \Sprint.createdAt, animation: .snappy) private var sprints: [Sprint]
    @Query(sort: TaskItem.displayOrder, animation: .snappy) private var tasks: [TaskItem]
    @Environment(AppRouter.self) private var router
    @Environment(\.localizer) private var t
    @State private var viewModel = ScopeViewModel()

    var body: some View {
        @Bindable var router = router
        let content = ScopeViewModel.makeContent(sprints: sprints, tasks: tasks, query: router.searchText)

        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                PageHeader(eyebrow: t(.personalProject), title: t(.scope), subtitle: summary(for: content)) {
                    Button(t(.createSprint)) { router.presentNewSprint() }
                        .buttonStyle(.neutralAction)
                }
                .padding(.bottom, 6)

                if content.isSearching && content.matchCount == 0 {
                    ContentUnavailableView.search(text: router.searchText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }

                ForEach(content.openSprints) { group in
                    SprintSection(
                        kind: .sprint(group.sprint),
                        tasks: group.tasks,
                        allTasks: group.allTasks,
                        moveTargets: content.moveTargets,
                        canStartSprint: !content.hasActiveSprint,
                        isSearching: content.isSearching,
                        isExpanded: viewModel.isExpanded(group.sprint.uuid.uuidString, defaultValue: true)
                    )
                }

                SprintSection(
                    kind: .backlog,
                    tasks: content.backlogTasks,
                    allTasks: content.allBacklogTasks,
                    moveTargets: content.moveTargets,
                    canStartSprint: !content.hasActiveSprint,
                    isSearching: content.isSearching,
                    isExpanded: viewModel.isExpanded(ScopeViewModel.backlogSectionID, defaultValue: true)
                )

                if !content.completedSprints.isEmpty {
                    completedSprints(content)
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Theme.surface)
        .navigationTitle(t(.scope))
        .hidesToolbarTitle()
        .searchable(text: $router.searchText, placement: .toolbar, prompt: Text(t(.searchTasks)))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    router.presentNewTask(activeSprint: nil)
                } label: {
                    Label(t(.createTask), systemImage: "plus")
                }
                .help(t(.createTaskHelp))
            }
        }
    }

    @ViewBuilder
    private func completedSprints(_ content: ScopeContent) -> some View {
        let isExpanded = viewModel.isExpanded(ScopeViewModel.completedGroupID, defaultValue: false)
        Button {
            withAnimation(.snappy) { isExpanded.wrappedValue.toggle() }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .rotationEffect(.degrees(isExpanded.wrappedValue ? 90 : 0))
                    .frame(width: 14)
                Text(t(.completedSprints))
                    .font(.system(size: 13, weight: .semibold))
                Text("(\(content.completedSprints.count))")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.textSubtlest)
            }
            .foregroundStyle(Theme.textSubtle)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.top, 10)

        if isExpanded.wrappedValue {
            ForEach(content.completedSprints) { group in
                SprintSection(
                    kind: .sprint(group.sprint),
                    tasks: group.tasks,
                    allTasks: group.allTasks,
                    moveTargets: content.moveTargets,
                    canStartSprint: false,
                    isSearching: content.isSearching,
                    isExpanded: viewModel.isExpanded(group.sprint.uuid.uuidString, defaultValue: false)
                )
            }
        }
    }

    private func summary(for content: ScopeContent) -> String {
        let openCount = content.openSprints.count
        return "\(t(.sprintCount(openCount))) · \(t(.taskCount(tasks.count)))"
    }
}

#if DEBUG
#Preview("Scope") {
    NavigationStack {
        ScopeView()
    }
    .previewEnvironment()
    .frame(width: 1000, height: 800)
}
#endif
