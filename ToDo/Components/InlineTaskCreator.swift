//
//  InlineTaskCreator.swift
//  ToDo
//
//  "+ Create task" button that turns into a text field, like Jira's quick create.
//  Return creates the task and keeps the field open for the next one; Escape closes it.
//

import SwiftUI

struct InlineTaskCreator: View {
    @Binding var isEditing: Bool
    let onCreate: (String) -> Void

    @Environment(\.localizer) private var t
    @State private var title = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        if isEditing {
            HStack(spacing: 8) {
                TaskTypeIcon()
                TextField(t(.titlePlaceholder), text: $title)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.text)
                    .focused($isFocused)
                    .onSubmit(submit)
                    .onExitCommand(perform: close)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 9)
            .background(Theme.raised, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 6, style: .continuous).strokeBorder(Theme.brand, lineWidth: 2))
            .task { isFocused = true }
            .onChange(of: isFocused) { _, focused in
                // Clicking elsewhere closes an empty field but keeps a half-typed title.
                if !focused && title.trimmingCharacters(in: .whitespaces).isEmpty {
                    close()
                }
            }
        } else {
            Button {
                isEditing = true
            } label: {
                Label(t(.createTask), systemImage: "plus")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.subtleAction)
        }
    }

    private func submit() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            close()
            return
        }
        withAnimation(.snappy) { onCreate(trimmed) }
        title = ""
        isFocused = true
    }

    private func close() {
        title = ""
        isEditing = false
    }
}
