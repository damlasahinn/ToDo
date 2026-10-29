//
//  SampleData.swift
//  ToDo
//
//  Debug-only demo content for SwiftUI previews and the `-DemoData` launch argument.
//  It is always written to an in-memory store, never to your real data.
//

#if DEBUG
import Foundation
import SwiftData
import SwiftUI

enum SampleData {
    static func populate(using store: ProjectStore) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        func day(_ offset: Int) -> Date {
            calendar.date(byAdding: .day, value: offset, to: today) ?? today
        }

        let first = SprintDraft(name: "Sprint 1", goal: "Project foundation", startDate: day(-21), endDate: day(-7))
        let sprint1 = store.createSprint(first)
        store.start(sprint1, with: first)
        for (title, priority) in [("Set up Xcode project", TaskPriority.high), ("Design data model", .medium), ("Sketch main navigation", .low)] {
            store.createTask(title: title, status: .done, priority: priority, sprint: sprint1)
        }
        store.complete(sprint1, movingOpenTasksTo: .keepInSprint)

        let second = SprintDraft(name: "Sprint 2", goal: "Usable Scope and Board screens", startDate: day(-4), endDate: day(10))
        let sprint2 = store.createSprint(second)
        store.start(sprint2, with: second)
        let activeTasks: [(String, TaskStatus, TaskPriority?)] = [
            ("Drag cards between Board columns", .inProgress, .high),
            ("Add Turkish translations", .todo, .medium),
            ("Sprint start and end date pickers", .test, .medium),
            ("Empty state for the Board", .todo, nil),
            ("Context menu for task rows", .done, .low),
            ("Keyboard shortcut for new tasks", .inProgress, .low),
            ("Persist the language preference", .done, .medium)
        ]
        for (title, status, priority) in activeTasks {
            store.createTask(title: title, details: "Example description for \(title.lowercased()).", status: status, priority: priority, sprint: sprint2)
        }

        let third = store.makeSprintDraft()
        let sprint3 = store.createSprint(third)
        store.createTask(title: "Export tasks as CSV", priority: .low, sprint: sprint3)
        store.createTask(title: "Menu bar quick add", priority: .medium, sprint: sprint3)

        for (title, priority) in [("Write user guide", TaskPriority?.none), ("Add app icon", .medium), ("Investigate iCloud backup", .low), ("Fix window restoration", .high)] {
            store.createTask(title: title, priority: priority)
        }
    }
}

/// Shared in-memory environment for `#Preview` blocks.
@MainActor
enum PreviewEnvironment {
    static let container: ModelContainer = {
        do {
            let container = try PersistenceController.makeContainer(inMemory: true)
            SampleData.populate(using: ProjectStore(context: container.mainContext))
            return container
        } catch {
            fatalError("Could not create the preview container: \(error)")
        }
    }()

    static let store = ProjectStore(context: container.mainContext)
}

extension View {
    func previewEnvironment(language: AppLanguage = .english) -> some View {
        self
            .modelContainer(PreviewEnvironment.container)
            .environment(PreviewEnvironment.store)
            .environment(AppRouter())
            .environment(\.localizer, Localizer(language: language))
            .environment(\.locale, language.locale)
    }
}
#endif
