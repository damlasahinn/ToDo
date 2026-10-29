//
//  SprintEditorView.swift
//  ToDo
//
//  One sheet for Create Sprint, Edit Sprint and Start Sprint.
//

import SwiftUI

struct SprintEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ProjectStore.self) private var store
    @Environment(\.localizer) private var t
    @State private var viewModel: SprintEditorViewModel

    init(mode: SprintEditorViewModel.Mode) {
        _viewModel = State(initialValue: SprintEditorViewModel(mode: mode))
    }

    var body: some View {
        @Bindable var viewModel = viewModel
        VStack(spacing: 0) {
            SheetHeader(
                title: title,
                subtitle: viewModel.isStarting ? t(.taskCount(viewModel.taskCount)) : nil,
                systemImage: viewModel.isStarting ? "play.fill" : "flag.fill",
                tint: Theme.brand
            )

            Form {
                if viewModel.isStarting {
                    Section {
                        Text(t(.startSprintMessage(viewModel.taskCount)))
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    TextField(t(.sprintName), text: $viewModel.name, prompt: Text(t(.sprintNamePlaceholder)))
                    Picker(t(.duration), selection: Binding(get: { viewModel.duration }, set: { viewModel.setDuration($0) })) {
                        ForEach(SprintDuration.allCases) { duration in
                            Text(t(duration.label)).tag(duration)
                        }
                    }
                    DatePicker(
                        t(.startDate),
                        selection: Binding(get: { viewModel.startDate }, set: { viewModel.setStartDate($0) }),
                        displayedComponents: .date
                    )
                    DatePicker(
                        t(.endDate),
                        selection: Binding(get: { viewModel.endDate }, set: { viewModel.setEndDate($0) }),
                        in: viewModel.startDate...,
                        displayedComponents: .date
                    )
                } footer: {
                    if !viewModel.isDateRangeValid {
                        Text(t(.invalidDateRange))
                            .foregroundStyle(.red)
                    }
                }
                .datePickerStyle(.compact)

                Section(t(.sprintGoal)) {
                    TextField(t(.sprintGoal), text: $viewModel.goal, prompt: Text(t(.sprintGoalPlaceholder)), axis: .vertical)
                        .lineLimit(3...6)
                        .labelsHidden()
                }
            }
            .formStyle(.grouped)

            SheetFooter {
                Spacer()
                Button(t(.cancel)) { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button(confirmTitle) {
                    viewModel.save(using: store)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.canSave)
            }
        }
        .frame(width: 520, height: viewModel.isStarting ? 540 : 470)
    }

    private var title: String {
        switch viewModel.mode {
        case .create: t(.createSprint)
        case .edit: t(.editSprint)
        case .start: t(.startSprint)
        }
    }

    private var confirmTitle: String {
        switch viewModel.mode {
        case .create: t(.create)
        case .edit: t(.save)
        case .start: t(.start)
        }
    }
}
