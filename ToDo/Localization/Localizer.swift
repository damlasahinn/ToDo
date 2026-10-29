//
//  Localizer.swift
//  ToDo
//
//  Views read the localizer from the environment and call it like a function:
//
//      @Environment(\.localizer) private var t
//      Text(t(.createTask))
//
//  The root of the app injects a localizer for the selected language, so changing the
//  language in Settings re-renders the whole interface immediately.
//

import SwiftUI

nonisolated struct Localizer: Sendable {
    var language: AppLanguage

    func callAsFunction(_ key: L10n) -> String {
        key.text(in: language)
    }

    var locale: Locale { language.locale }

    /// Upper-cases using the language's rules (Turkish "i" becomes "İ").
    func uppercased(_ key: L10n) -> String {
        key.text(in: language).uppercased(with: locale)
    }
}

nonisolated private struct LocalizerKey: EnvironmentKey {
    static let defaultValue = Localizer(language: .english)
}

extension EnvironmentValues {
    nonisolated var localizer: Localizer {
        get { self[LocalizerKey.self] }
        set { self[LocalizerKey.self] = newValue }
    }
}
