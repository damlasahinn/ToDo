//
//  ToDoApp.swift
//  ToDo
//
//  Created by Damla Sahin on 29.10.2026.
//

import SwiftData
import SwiftUI

@main
struct ToDoApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @AppStorage(PreferenceKey.language) private var language: AppLanguage = .english
    @AppStorage(PreferenceKey.appearance) private var appearance: AppAppearance = .dark
    @State private var router = AppRouter()
    private let launch = LaunchState.make()

    private var localizer: Localizer { Localizer(language: language) }

    var body: some Scene {
        Window("ToDo", id: "main") {
            Group {
                switch launch {
                case .ready(let container, let store):
                    RootView()
                        .modelContainer(container)
                        .environment(store)
                case .failed(let message):
                    StoreErrorView(message: message)
                }
            }
            .environment(router)
            .environment(\.localizer, localizer)
            .environment(\.locale, language.locale)
            .frame(minWidth: 960, minHeight: 600)
            .onChange(of: appearance) { _, newValue in
                newValue.apply()
            }
        }
        .defaultSize(width: 1280, height: 820)
        .commands {
            AppCommands(router: router, store: launch.store, localizer: localizer)
        }
    }
}

/// The result of opening the database at launch.
enum LaunchState {
    case ready(ModelContainer, ProjectStore)
    case failed(String)

    var store: ProjectStore? {
        if case .ready(_, let store) = self { store } else { nil }
    }

    static func make() -> LaunchState {
        do {
            #if DEBUG
            // Launch with "-DemoData YES" (Product › Scheme › Edit Scheme › Arguments) to try
            // the app with sample content in memory, without touching your real data.
            let usesDemoData = UserDefaults.standard.bool(forKey: "DemoData")
            #else
            let usesDemoData = false
            #endif
            let container = try PersistenceController.makeContainer(inMemory: usesDemoData)
            let store = ProjectStore(context: container.mainContext)
            #if DEBUG
            if usesDemoData {
                SampleData.populate(using: store)
            }
            #endif
            return .ready(container, store)
        } catch {
            return .failed(String(describing: error))
        }
    }
}
