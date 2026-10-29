//
//  AppLanguage.swift
//  ToDo
//

import Foundation

nonisolated enum AppLanguage: String, CaseIterable, Identifiable, Sendable {
    case english = "en"
    case turkish = "tr"

    var id: String { rawValue }

    /// Shown in the language picker, always written in the language itself.
    var nativeName: String {
        switch self {
        case .english: "English"
        case .turkish: "Türkçe"
        }
    }

    /// Locale used for date pickers, date formatting and upper-casing.
    /// English keeps the Mac's region so dates still follow the user's usual format.
    var locale: Locale {
        switch self {
        case .english:
            let region = Locale.current.region?.identifier ?? "US"
            return Locale(identifier: "en_\(region)")
        case .turkish:
            return Locale(identifier: "tr_TR")
        }
    }
}
