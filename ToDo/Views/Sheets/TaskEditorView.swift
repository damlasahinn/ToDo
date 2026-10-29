//
//  TaskEditorView.swift
//  ToDo
//
//  Sheet for creating and editing a task. Return saves, Escape cancels.
//

import SwiftData
import SwiftUI

struct TaskEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ProjectStore.self) private var store
    @Environment(\.localizer) private var t
    @Query(sort: \Sprint.createdAt) private var sprints: [Sprint]
    @State private var viewModel: TaskEditorViewModel
    @State private var isConfirmingDelete = false
    @FocusState private var isTitleFocused: Bool

    init(mode: TaskEditorViewModel.Mode) {
        _viewModel = State(initialValue: TaskEditorViewModel(mode: mode))
    }

    var body: some View {
        @Bindable var viewModel = viewModel
        VStack(spacing: 0) {
            SheetHeader(
                title: viewModel.taskKey ?? t(.createTask),
                subtitle: viewModel.isEditing ? t(.editTask) : t(.createTaskSubtitle),
                systemImage: "checkmark.square.fill"
            )

            Form {
                Section {
                    TextField(t(.title), text: $viewModel.title, prompt: Text(t(.titlePlaceholder)))
                        .focused($isTitleFocused)
                }

                Section(t(.description)) {
                    TextEditor(text: $viewModel.details)
                        .font(.body)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 110)
                        .overlay(alignment: .topLeading) {
                            if viewModel.details.isEmpty {
                                Text(t(.descriptionPlaceholder))
                                    .foregroundStyle(.tertiary)
                                    .padding(.leading, 5)
                                    .allowsHitTesting(false)
                            }
                        }
                }

                Section {
                    Picker(t(.status), selection: $viewModel.status) {
                        ForEach(TaskStatus.allCases) { status in
                            Text(t(status.label)).tag(status)
                        }
                    }
                    Picker(t(.priority), selection: $viewModel.priority) {
                        Text(t(.priorityNone)).tag(TaskPriority?.none)
                        ForEach(TaskPriority.allCases) { priority in
                            Text(t(priority.label)).tag(TaskPriority?.some(priority))
                        }
                    }
                    Picker(t(.sprint), selection: $viewModel.sprint) {
                        Text(t(.backlog)).tag(Sprint?.none)
                        ForEach(viewModel.sprintOptions(from: sprints)) { sprint in
                            Text(sprintLabel(sprint)).tag(Sprint?.some(sprint))
                        }
                    }
                }

                if let createdAt = viewModel.createdAt, let updatedAt = viewModel.updatedAt {
                    Section {
                        LabeledContent(t(.created), value: DateFormatting.medium(createdAt, locale: t.locale, includingTime: true))
                        LabeledContent(t(.updated), value: DateFormatting.medium(updatedAt, locale: t.locale, includingTime: true))
                    }
                }
            }
            .formStyle(.grouped)

            SheetFooter {
                if viewModel.isEditing {
                    Button(t(.delete), role: .destructive) {
                        isConfirmingDelete = true
                    }
                }
                Spacer()
                Button(t(.cancel)) { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button(viewModel.isEditing ? t(.save) : t(.create)) {
                    viewModel.save(using: store)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.canSave)
            }
        }
        .frame(width: 560, height: viewModel.isEditing ? 640 : 560)
        .task { isTitleFocused = !viewModel.isEditing }
        .alert(t(.deleteTaskTitle(viewModel.taskKey ?? "")), isPresented: $isConfirmingDelete) {
            Button(t(.delete), role: .destructive) {
                guard let task = viewModel.editedTask else { return }
                dismiss()
                store.delete(task)
            }
            Button(t(.cancel), role: .cancel) {}
        } message: {
            Text(t(.deleteTaskMessage))
        }
    }

    private func sprintLabel(_ sprint: Sprint) -> String {
        sprint.state == .planned ? sprint.name : "\(sprint.name) (\(t(sprint.state.label)))"
    }
}

#if DEBUG
#Preview("New task") {
    TaskEditorView(mode: .create(sprint: nil, status: .todo))
        .previewEnvironment()
}
#endif
