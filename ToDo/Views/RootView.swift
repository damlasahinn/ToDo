//
//  RootView.swift
//  ToDo
//
//  The main window: sidebar navigation, the selected screen, and every sheet and
//  confirmation alert (presented from one place so the menu bar can trigger them too).
//

import SwiftData
import SwiftUI

struct RootView: View {
    @Environment(AppRouter.self) private var router
    @Environment(ProjectStore.self) private var store
    @Environment(\.localizer) private var t

    var body: some View {
        @Bindable var router = router
        NavigationSplitView {
            SidebarView()
                .navigationSplitViewColumnWidth(min: 190, ideal: 220, max: 300)
        } detail: {
            switch router.selection {
            case .scope: ScopeView()
            case .board: BoardView()
            case .settings: SettingsView()
            }
        }
        .sheet(item: $router.sheet) { route in
            SheetContent(route: route)
                .modelContext(store.context)
                .environment(store)
                .environment(router)
                .environment(\.localizer, t)
                .environment(\.locale, t.locale)
        }
        .alert(
            t(.deleteTaskTitle(router.taskDeletion?.key ?? "")),
            isPresented: Binding(
                get: { router.taskDeletion != nil },
                set: { if !$0 { router.taskDeletion = nil } }
            ),
            presenting: router.taskDeletion
        ) { request in
            Button(t(.delete), role: .destructive) {
                withAnimation(.snappy) { store.delete(request.task) }
            }
            Button(t(.cancel), role: .cancel) {}
        } message: { _ in
            Text(t(.deleteTaskMessage))
        }
        .alert(
            t(.deleteSprintTitle(router.sprintDeletion?.name ?? "")),
            isPresented: Binding(
                get: { router.sprintDeletion != nil },
                set: { if !$0 { router.sprintDeletion = nil } }
            ),
            presenting: router.sprintDeletion
        ) { request in
            Button(t(.delete), role: .destructive) {
                withAnimation(.snappy) { store.delete(request.sprint) }
            }
            Button(t(.cancel), role: .cancel) {}
        } message: { request in
            Text(t(.deleteSprintMessage(request.taskCount)))
        }
        .alert(
            t(.saveFailedTitle),
            isPresented: Binding(
                get: { store.saveErrorMessage != nil },
                set: { if !$0 { store.saveErrorMessage = nil } }
            )
        ) {
            Button(t(.ok)) {}
        } message: {
            Text(t(.saveFailedMessage(store.saveErrorMessage ?? "")))
        }
    }
}

private struct SheetContent: View {
    let route: SheetRoute
    @Environment(ProjectStore.self) private var store

    var body: some View {
        switch route.kind {
        case .createTask(let sprint, let status):
            TaskEditorView(mode: .create(sprint: sprint, status: status))
        case .editTask(let task):
            TaskEditorView(mode: .edit(task))
        case .createSprint:
            SprintEditorView(mode: .create(store.makeSprintDraft()))
        case .editSprint(let sprint):
            SprintEditorView(mode: .edit(sprint))
        case .startSprint(let sprint):
            SprintEditorView(mode: .start(sprint))
        case .completeSprint(let sprint):
            CompleteSprintView(sprint: sprint)
        }
    }
}

extension View {
    /// The content area draws its own large title, so the toolbar title is hidden where
    /// macOS allows it (macOS 15+). The window title stays for the Window menu.
    @ViewBuilder
    func hidesToolbarTitle() -> some View {
        if #available(macOS 15.0, *) {
            toolbar(removing: .title)
        } else {
            self
        }
    }
}

#if DEBUG
#Preview("Main window") {
    RootView()
        .previewEnvironment()
        .frame(width: 1200, height: 760)
}
#endif
