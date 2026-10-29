//
//  IdentifierSequence.swift
//  ToDo
//

import Foundation
import SwiftData

/// A persisted counter, so task numbers keep increasing even after tasks are deleted
/// (TASK-5 is never handed out twice).
@Model
final class IdentifierSequence {
    var name: String = ""
    var nextValue: Int = 1

    init(name: String, nextValue: Int) {
        self.name = name
        self.nextValue = nextValue
    }
}
