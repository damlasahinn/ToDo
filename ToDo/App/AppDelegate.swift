//
//  AppDelegate.swift
//  ToDo
//

import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {
        // Apply the saved appearance before the window appears, so it never flashes light.
        AppAppearance.stored.apply()
    }

    /// The app has a single window; closing it quits the app.
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
