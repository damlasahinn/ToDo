//
//  BoardViewModel.swift
//  ToDo
//
//  Splits the active sprint's tasks into the four Board columns.
//

import Foundation

struct BoardColumnData: Identifiable {
    let status: TaskStatus
    let tasks: [TaskItem]

    var id: TaskStatus { status }
}

struct BoardViewModel {
    let sprint: Sprint
    let columns: [BoardColumnData]
    let totalCount: Int
    let doneCount: Int

    init(sprint: Sprint, tasks: [TaskItem], query: String) {
        self.sprint = sprint
        let sprintTasks = tasks.filter { $0.sprint?.uuid == sprint.uuid }
        let visible = sprintTasks.filter { $0.matches(query) }
        columns = TaskStatus.allCases.map { status in
            BoardColumnData(status: status, tasks: visible.filter { $0.status == status })
        }
        totalCount = sprintTasks.count
        doneCount = sprintTasks.filter(\.isDone).count
    }

    var progress: Double {
        totalCount == 0 ? 0 : Double(doneCount) / Double(totalCount)
    }
}
