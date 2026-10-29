//
//  TaskItem.swift
//  ToDo
//
//  Named TaskItem (not Task) to avoid clashing with Swift Concurrency's Task type.
//

import Foundation
import SwiftData

@Model
final class TaskItem {
    /// Stable identifier used for drag and drop and sheet identity.
    var uuid: UUID = UUID()
    /// Sequential number shown as the task key (TASK-<number>). Numbers are never reused.
    var number: Int = 0
    var title: String = ""
    var details: String = ""
    /// Enums are stored as raw strings so they stay readable and safe to migrate.
    var statusRawValue: String = TaskStatus.todo.rawValue
    var priorityRawValue: String?
    /// Manual ordering shared by the Scope lists and the Board columns (lower comes first).
    var rank: Double = 0
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now
    /// `nil` means the task lives in the Backlog.
    var sprint: Sprint?

    init(
        number: Int,
        title: String,
        details: String = "",
        status: TaskStatus = .todo,
        priority: TaskPriority? = nil,
        rank: Double
    ) {
        self.number = number
        self.title = title
        self.details = details
        self.statusRawValue = status.rawValue
        self.priorityRawValue = priority?.rawValue
        self.rank = rank
        self.createdAt = .now
        self.updatedAt = .now
    }
}

extension TaskItem {
    static let keyPrefix = "TASK"

    /// Sort order used everywhere tasks are listed.
    static var displayOrder: [SortDescriptor<TaskItem>] {
        [SortDescriptor(\.rank), SortDescriptor(\.number)]
    }

    var status: TaskStatus {
        get { TaskStatus(rawValue: statusRawValue) ?? .todo }
        set { statusRawValue = newValue.rawValue }
    }

    var priority: TaskPriority? {
        get { priorityRawValue.flatMap(TaskPriority.init(rawValue:)) }
        set { priorityRawValue = newValue?.rawValue }
    }

    var key: String { "\(Self.keyPrefix)-\(number)" }

    var isDone: Bool { status == .done }

    /// Case- and diacritic-insensitive search over the key, title and description.
    func matches(_ query: String) -> Bool {
        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return true }
        return key.localizedStandardContains(query)
            || title.localizedStandardContains(query)
            || details.localizedStandardContains(query)
    }
}
