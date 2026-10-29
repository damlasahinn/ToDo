//
//  SettingsView.swift
//  ToDo
//

import AppKit
import SwiftData
import SwiftUI

struct SettingsView: View {
    @AppStorage(PreferenceKey.language) private var language: AppLanguage = .english
    @AppStorage(PreferenceKey.appearance) private var appearance: AppAppearance = .dark
    @Query private var tasks: [TaskItem]
    @Query private var sprints: [Sprint]
    @Environment(\.localizer) private var t

    var body: some View {
        Form {
            Section {
                Picker(t(.language), selection: $language) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(language.nativeName).tag(language)
                    }
                }
            } footer: {
                Text(t(.languageFooter))
                    .foregroundStyle(.secondary)
            }

            Section {
                Picker(t(.appearance), selection: $appearance) {
                    ForEach(AppAppearance.allCases) { appearance in
                        Text(t(appearance.label)).tag(appearance)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section {
                LabeledContent(t(.storedTasks), value: "\(tasks.count)")
                LabeledContent(t(.storedSprints), value: "\(sprints.count)")
                LabeledContent(t(.storageLocation)) {
                    Text(PersistenceController.storeURL.path(percentEncoded: false))
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                        .lineLimit(3)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Spacer()
                    Button(t(.showInFinder)) {
                        NSWorkspace.shared.activateFileViewerSelecting([PersistenceController.storeURL])
                    }
                }
            } header: {
                Text(t(.data))
            } footer: {
                Text(t(.dataFooter))
                    .foregroundStyle(.secondary)
            }

            Section(t(.keyboardShortcuts)) {
                shortcut(t(.newTaskMenu), "⌘N")
                shortcut(t(.newSprintMenu), "⇧⌘N")
                shortcut(t(.scope), "⌘1")
                shortcut(t(.board), "⌘2")
                shortcut(t(.settings), "⌘,")
            }

            Section {
                LabeledContent(t(.version), value: appVersion)
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .frame(maxWidth: 680)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.surface)
        .navigationTitle(t(.settings))
    }

    private func shortcut(_ title: String, _ keys: String) -> some View {
        LabeledContent(title) {
            Text(keys)
                .font(.system(size: 12, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }

    private var appVersion: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = info?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

#if DEBUG
#Preview("Settings") {
    SettingsView()
        .previewEnvironment()
        .frame(width: 800, height: 700)
}
#endif
