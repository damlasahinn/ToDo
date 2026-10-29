//
//  CompleteSprintView.swift
//  ToDo
//

import SwiftData
import SwiftUI

struct CompleteSprintView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ProjectStore.self) private var store
    @Environment(\.localizer) private var t
    @Query(sort: \Sprint.createdAt) private var sprints: [Sprint]
    @State private var viewModel: CompleteSprintViewModel

    init(sprint: Sprint) {
        _viewModel = State(initialValue: CompleteSprintViewModel(sprint: sprint))
    }

    var body: some View {
        @Bindable var viewModel = viewModel
        VStack(spacing: 0) {
            SheetHeader(
                title: t(.completeSprint),
                subtitle: viewModel.sprint.name,
                systemImage: "flag.checkered",
                tint: Theme.accent(.done)
            )

            Form {
                Section {
                    HStack(spacing: 12) {
                        statTile(value: viewModel.doneCount, label: t(.completedTasks), color: Theme.accent(.done))
                        statTile(value: viewModel.openCount, label: t(.openTasks), color: Theme.accent(.inProgress))
                    }
                    .padding(.vertical, 4)
                }

                if viewModel.openCount > 0 {
                    Section {
                        Picker(t(.moveOpenTasksTo), selection: $viewModel.destination) {
                            Text(t(.keepInCompletedSprint)).tag(OpenTaskDestination.keepInSprint)
                            Text(t(.backlog)).tag(OpenTaskDestination.backlog)
                            ForEach(viewModel.plannedSprints(from: sprints)) { sprint in
                                Text(sprint.name).tag(OpenTaskDestination.sprint(sprint))
                            }
                        }
                    } footer: {
                        Text(t(.openTasksFooter))
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    Label(t(.completeSprintNote), systemImage: "archivebox")
                        .foregroundStyle(.secondary)
                }
            }
            .formStyle(.grouped)

            SheetFooter {
                Spacer()
                Button(t(.cancel)) { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button(t(.completeSprint)) {
                    withAnimation(.snappy) { viewModel.complete(using: store) }
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(width: 500, height: viewModel.openCount > 0 ? 450 : 360)
    }

    private func statTile(value: Int, label: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(value)")
                .font(.system(size: 26, weight: .semibold).monospacedDigit())
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
