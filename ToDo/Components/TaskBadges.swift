//
//  TaskBadges.swift
//  ToDo
//
//  Small visual building blocks shared by rows, cards and headers.
//

import SwiftUI

/// Uppercase status label, like Jira's lozenges.
struct StatusLozenge: View {
    let status: TaskStatus
    var showsChevron = false
    @Environment(\.localizer) private var t

    var body: some View {
        HStack(spacing: 4) {
            Text(t.uppercased(status.label))
                .font(.system(size: 11, weight: .bold))
                .lineLimit(1)
            if showsChevron {
                Image(systemName: "chevron.down")
                    .font(.system(size: 8, weight: .bold))
            }
        }
        .foregroundStyle(Theme.lozengeForeground(status))
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(Theme.lozengeBackground(status), in: RoundedRectangle(cornerRadius: 3, style: .continuous))
        .fixedSize()
    }
}

/// The blue "task" checkbox icon shown before every task key.
struct TaskTypeIcon: View {
    var body: some View {
        Image(systemName: "checkmark.square.fill")
            .symbolRenderingMode(.palette)
            .foregroundStyle(.white, Theme.taskIcon)
            .font(.system(size: 14))
            .accessibilityHidden(true)
    }
}

struct PriorityIcon: View {
    let priority: TaskPriority?
    @Environment(\.localizer) private var t

    var body: some View {
        if let priority {
            Image(systemName: symbolName(for: priority))
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Theme.priorityColor(priority))
                .frame(width: 16, height: 16)
                .help("\(t(.priority)): \(t(priority.label))")
                .accessibilityLabel("\(t(.priority)): \(t(priority.label))")
        } else {
            Color.clear.frame(width: 16, height: 16)
        }
    }

    private func symbolName(for priority: TaskPriority) -> String {
        switch priority {
        case .high: "chevron.up.2"
        case .medium: "equal"
        case .low: "chevron.down"
        }
    }
}

/// The task key, struck through once the task is done (as in Jira).
struct TaskKeyLabel: View {
    let task: TaskItem

    var body: some View {
        Text(task.key)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(Theme.textSubtle)
            .strikethrough(task.isDone, color: Theme.textSubtle)
            .lineLimit(1)
            .fixedSize()
    }
}

/// Per-status task counters shown in sprint headers.
struct StatusCountPills: View {
    let tasks: [TaskItem]
    @Environment(\.localizer) private var t

    var body: some View {
        HStack(spacing: 4) {
            ForEach(TaskStatus.allCases) { status in
                let count = tasks.filter { $0.status == status }.count
                Text("\(count)")
                    .font(.system(size: 11, weight: .semibold).monospacedDigit())
                    .foregroundStyle(Theme.lozengeForeground(status))
                    .padding(.horizontal, 6)
                    .frame(minWidth: 22, minHeight: 18)
                    .background(Theme.lozengeBackground(status), in: Capsule())
                    .help("\(t(status.label)): \(count)")
            }
        }
        .accessibilityElement(children: .combine)
    }
}

struct SprintStateBadge: View {
    let state: SprintState
    @Environment(\.localizer) private var t

    var body: some View {
        Text(t.uppercased(state.label))
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(foreground)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(background, in: RoundedRectangle(cornerRadius: 3, style: .continuous))
            .fixedSize()
    }

    private var foreground: Color {
        switch state {
        case .planned: Theme.lozengeForeground(.todo)
        case .active: Theme.lozengeForeground(.inProgress)
        case .completed: Theme.lozengeForeground(.done)
        }
    }

    private var background: Color {
        switch state {
        case .planned: Theme.lozengeBackground(.todo)
        case .active: Theme.lozengeBackground(.inProgress)
        case .completed: Theme.lozengeBackground(.done)
        }
    }
}

/// Compact card that follows the pointer while a task is being dragged.
struct TaskDragPreview: View {
    let task: TaskItem

    var body: some View {
        HStack(spacing: 8) {
            TaskTypeIcon()
            TaskKeyLabel(task: task)
            Text(task.title)
                .font(.system(size: 13))
                .foregroundStyle(Theme.text)
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(width: 280, alignment: .leading)
        .background(Theme.raised, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).strokeBorder(Theme.brand, lineWidth: 1))
    }
}

/// Dashed placeholder used for empty sprints and the empty Backlog.
struct EmptyDropZone: View {
    let title: String?
    let message: String

    var body: some View {
        VStack(spacing: 4) {
            if let title {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.text)
            }
            Text(message)
                .font(.system(size: 12))
                .foregroundStyle(Theme.textSubtle)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .overlay(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .strokeBorder(Theme.border, style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
        )
    }
}

/// Large page title used at the top of Scope and Board.
struct PageHeader<Accessory: View>: View {
    let eyebrow: String
    let title: String
    let subtitle: String?
    @ViewBuilder var accessory: Accessory

    var body: some View {
        HStack(alignment: .bottom, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(eyebrow)
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.textSubtlest)
                Text(title)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Theme.text)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.textSubtle)
                }
            }
            Spacer(minLength: 16)
            accessory
        }
    }
}
