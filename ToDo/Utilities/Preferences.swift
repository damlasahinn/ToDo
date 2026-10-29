//
//  Preferences.swift
//  ToDo
//
//  Simple preferences stored in UserDefaults via @AppStorage.
//  Tasks and sprints are never stored here; they live in SwiftData.
//

import AppKit
import Foundation

nonisolated enum PreferenceKey {
    static let language = "appLanguage"
    static let appearance = "appAppearance"
}

nonisolated enum AppAppearance: String, CaseIterable, Identifiable, Sendable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var label: L10n {
        switch self {
        case .system: .appearanceSystem
        case .light: .appearanceLight
        case .dark: .appearanceDark
        }
    }

    /// Dark is the initial appearance until the user picks something else.
    static var stored: AppAppearance {
        UserDefaults.standard.string(forKey: PreferenceKey.appearance)
            .flatMap(AppAppearance.init(rawValue:)) ?? .dark
    }

    /// Applying the appearance at the app level also covers sheets, menus and alerts.
    @MainActor
    func apply() {
        switch self {
        case .system: NSApp.appearance = nil
        case .light: NSApp.appearance = NSAppearance(named: .aqua)
        case .dark: NSApp.appearance = NSAppearance(named: .darkAqua)
        }
    }
}
