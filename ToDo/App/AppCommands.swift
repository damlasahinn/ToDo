//
//  AppCommands.swift
//  ToDo
//
//  Menu bar items and their keyboard shortcuts.
//

import SwiftUI

struct AppCommands: Commands {
    let router: AppRouter
    let store: ProjectStore?
    let localizer: Localizer

    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button(localizer(.newTaskMenu)) {
                router.presentNewTask(activeSprint: store?.activeSprint())
            }
            .keyboardShortcut("n", modifiers: .command)
            .disabled(store == nil)

            Button(localizer(.newSprintMenu)) {
                router.presentNewSprint()
            }
            .keyboardShortcut("n", modifiers: [.command, .shift])
            .disabled(store == nil)
        }

        // Settings live in the sidebar, so ⌘, simply navigates there.
        CommandGroup(replacing: .appSettings) {
            Button(localizer(.settingsMenu)) {
                router.selection = .settings
            }
            .keyboardShortcut(",", modifiers: .command)
        }

        CommandGroup(before: .sidebar) {
            Button(localizer(.scope)) { router.selection = .scope }
                .keyboardShortcut("1", modifiers: .command)
            Button(localizer(.board)) { router.selection = .board }
                .keyboardShortcut("2", modifiers: .command)
            Divider()
        }
    }
}
