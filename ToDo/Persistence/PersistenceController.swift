//
//  PersistenceController.swift
//  ToDo
//

import Foundation
import SwiftData

enum PersistenceController {
    static let schema = Schema([TaskItem.self, Sprint.self, IdentifierSequence.self])

    /// Because the app is sandboxed this resolves to
    /// ~/Library/Containers/com.info.ToDo/Data/Library/Application Support/ToDo/ToDo.store
    static var storeURL: URL {
        URL.applicationSupportDirectory
            .appending(path: "ToDo", directoryHint: .isDirectory)
            .appending(path: "ToDo.store", directoryHint: .notDirectory)
    }

    /// Opens (or creates) the on-disk store. The store is never deleted or reset here:
    /// if it cannot be opened, the error is shown to the user instead.
    static func makeContainer(inMemory: Bool = false) throws -> ModelContainer {
        let configuration: ModelConfiguration
        if inMemory {
            configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        } else {
            try FileManager.default.createDirectory(
                at: storeURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            configuration = ModelConfiguration(schema: schema, url: storeURL, cloudKitDatabase: .none)
        }
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
