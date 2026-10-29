//
//  StoreErrorView.swift
//  ToDo
//
//  Shown instead of the app if the database cannot be opened. Your data file is left
//  untouched so nothing is lost.
//

import AppKit
import SwiftUI

struct StoreErrorView: View {
    let message: String
    @Environment(\.localizer) private var t

    var body: some View {
        ContentUnavailableView {
            Label(t(.storeErrorTitle), systemImage: "externaldrive.badge.exclamationmark")
        } description: {
            VStack(spacing: 8) {
                Text(t(.storeErrorMessage))
                Text(message)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
            }
        } actions: {
            HStack {
                Button(t(.showInFinder)) {
                    NSWorkspace.shared.activateFileViewerSelecting([PersistenceController.storeURL])
                }
                Button(t(.quit)) {
                    NSApp.terminate(nil)
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(40)
    }
}
