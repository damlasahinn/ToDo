//
//  L10n.swift
//  ToDo
//
//  Every user-facing string in the app. Each case returns its English and Turkish text
//  side by side; because the switch is exhaustive, the compiler refuses to build if a
//  translation is missing. To add a string: add a case, then its pair in `translations`.
//

import Foundation

nonisolated enum L10n: Sendable {
    // Navigation
    case scope, board, settings, planning, personalProject, activeSprint

    // Task status
    case statusToDo, statusInProgress, statusTest, statusDone

    // Priority
    case priority, priorityNone, priorityHigh, priorityMedium, priorityLow

    // Sprint state
    case sprintPlanned, sprintActive, sprintCompleted

    // Common
    case cancel, save, create, start, delete, ok, quit, backlog, sprint, status
    case collapse, expand, moreActions, moveTo, changeStatus

    // Menu bar
    case newTaskMenu, newSprintMenu, settingsMenu

    // Tasks
    case createTask, createTaskHelp, createTaskSubtitle, editTask, editTaskEllipsis, deleteTaskEllipsis
    case title, titlePlaceholder, description, descriptionPlaceholder, created, updated
    case taskCount(Int)
    case filteredTaskCount(Int, Int)
    case deleteTaskTitle(String)
    case deleteTaskMessage

    // Sprints
    case createSprint, editSprint, editSprintEllipsis, startSprint, startSprintHelp, completeSprint
    case deleteSprintEllipsis, anotherSprintActive, completedSprints
    case sprintName, sprintNamePlaceholder, sprintGoal, sprintGoalPlaceholder
    case duration, durationCustom, startDate, endDate, invalidDateRange
    case durationWeeks(Int)
    case sprintCount(Int)
    case startNamedSprint(String)
    case startSprintMessage(Int)
    case completedOn(String)
    case daysRemaining(Int)
    case deleteSprintTitle(String)
    case deleteSprintMessage(Int)

    // Complete sprint
    case completedTasks, openTasks, moveOpenTasksTo, keepInCompletedSprint, openTasksFooter, completeSprintNote

    // Scope & Board
    case searchTasks, noMatchingTasks, emptyBacklog, emptySprintTitle, emptySprintMessage, completedSprintEmpty
    case noActiveSprintTitle, noActiveSprintMessage, goToScope
    case tasksDone(Int, Int)

    // Settings
    case language, languageFooter, appearance, appearanceSystem, appearanceLight, appearanceDark
    case data, dataFooter, storedTasks, storedSprints, storageLocation, showInFinder
    case keyboardShortcuts, version

    // Errors
    case saveFailedTitle
    case saveFailedMessage(String)
    case storeErrorTitle, storeErrorMessage

    func text(in language: AppLanguage) -> String {
        let pair = translations
        return language == .turkish ? pair.tr : pair.en
    }

    private var translations: (en: String, tr: String) {
        switch self {
        // Navigation
        case .scope: ("Scope", "Kapsam")
        case .board: ("Board", "Pano")
        case .settings: ("Settings", "Ayarlar")
        case .planning: ("Planning", "Planlama")
        case .personalProject: ("Personal project", "Kişisel proje")
        case .activeSprint: ("Active sprint", "Aktif sprint")

        // Task status
        case .statusToDo: ("To Do", "Yapılacak")
        case .statusInProgress: ("In Progress", "Devam Ediyor")
        case .statusTest: ("Test", "Test")
        case .statusDone: ("Done", "Tamamlandı")

        // Priority
        case .priority: ("Priority", "Öncelik")
        case .priorityNone: ("None", "Yok")
        case .priorityHigh: ("High", "Yüksek")
        case .priorityMedium: ("Medium", "Orta")
        case .priorityLow: ("Low", "Düşük")

        // Sprint state
        case .sprintPlanned: ("Planned", "Planlandı")
        case .sprintActive: ("Active", "Aktif")
        case .sprintCompleted: ("Completed", "Tamamlandı")

        // Common
        case .cancel: ("Cancel", "İptal")
        case .save: ("Save", "Kaydet")
        case .create: ("Create", "Oluştur")
        case .start: ("Start", "Başlat")
        case .delete: ("Delete", "Sil")
        case .ok: ("OK", "Tamam")
        case .quit: ("Quit", "Çık")
        case .backlog: ("Backlog", "İş Havuzu")
        case .sprint: ("Sprint", "Sprint")
        case .status: ("Status", "Durum")
        case .collapse: ("Collapse", "Daralt")
        case .expand: ("Expand", "Genişlet")
        case .moreActions: ("More actions", "Diğer işlemler")
        case .moveTo: ("Move To", "Taşı")
        case .changeStatus: ("Change status", "Durumu değiştir")

        // Menu bar
        case .newTaskMenu: ("New Task", "Yeni Görev")
        case .newSprintMenu: ("New Sprint", "Yeni Sprint")
        case .settingsMenu: ("Settings…", "Ayarlar…")

        // Tasks
        case .createTask: ("Create Task", "Görev Oluştur")
        case .createTaskHelp: ("Create a new task (⌘N)", "Yeni görev oluştur (⌘N)")
        case .createTaskSubtitle: ("Add a task to the Backlog or a sprint", "İş Havuzu'na veya bir sprinte görev ekleyin")
        case .editTask: ("Edit Task", "Görevi Düzenle")
        case .editTaskEllipsis: ("Edit Task…", "Görevi Düzenle…")
        case .deleteTaskEllipsis: ("Delete Task…", "Görevi Sil…")
        case .title: ("Title", "Başlık")
        case .titlePlaceholder: ("What needs to be done?", "Ne yapılması gerekiyor?")
        case .description: ("Description", "Açıklama")
        case .descriptionPlaceholder: ("Add a description…", "Açıklama ekleyin…")
        case .created: ("Created", "Oluşturulma")
        case .updated: ("Updated", "Güncellenme")
        case .taskCount(let count):
            (count == 1 ? "1 task" : "\(count) tasks", "\(count) görev")
        case .filteredTaskCount(let shown, let total):
            ("\(shown) of \(total) tasks", "\(shown)/\(total) görev")
        case .deleteTaskTitle(let key):
            ("Delete \(key)?", "\(key) silinsin mi?")
        case .deleteTaskMessage:
            ("This task will be permanently deleted. This can't be undone.",
             "Bu görev kalıcı olarak silinecek. Bu işlem geri alınamaz.")

        // Sprints
        case .createSprint: ("Create Sprint", "Sprint Oluştur")
        case .editSprint: ("Edit Sprint", "Sprint'i Düzenle")
        case .editSprintEllipsis: ("Edit Sprint…", "Sprint'i Düzenle…")
        case .startSprint: ("Start Sprint", "Sprint'i Başlat")
        case .startSprintHelp: ("Start working on this sprint", "Bu sprint üzerinde çalışmaya başlayın")
        case .completeSprint: ("Complete Sprint", "Sprint'i Tamamla")
        case .deleteSprintEllipsis: ("Delete Sprint…", "Sprint'i Sil…")
        case .anotherSprintActive:
            ("Complete the active sprint before starting another one.",
             "Başka bir sprint başlatmadan önce aktif sprinti tamamlayın.")
        case .completedSprints: ("Completed Sprints", "Tamamlanan Sprintler")
        case .sprintName: ("Sprint name", "Sprint adı")
        case .sprintNamePlaceholder: ("e.g. Sprint 4", "ör. Sprint 4")
        case .sprintGoal: ("Sprint goal", "Sprint hedefi")
        case .sprintGoalPlaceholder: ("What should this sprint achieve?", "Bu sprint neyi başarmalı?")
        case .duration: ("Duration", "Süre")
        case .durationCustom: ("Custom", "Özel")
        case .startDate: ("Start date", "Başlangıç tarihi")
        case .endDate: ("End date", "Bitiş tarihi")
        case .invalidDateRange:
            ("The end date can't be before the start date.", "Bitiş tarihi başlangıç tarihinden önce olamaz.")
        case .durationWeeks(let weeks):
            (weeks == 1 ? "1 week" : "\(weeks) weeks", "\(weeks) hafta")
        case .sprintCount(let count):
            (count == 1 ? "1 open sprint" : "\(count) open sprints", "\(count) açık sprint")
        case .startNamedSprint(let name):
            ("Start \(name)", "Başlat: \(name)")
        case .startSprintMessage(let count):
            count == 0
                ? ("This sprint has no tasks yet. You can add them later from Scope or the Board.",
                   "Bu sprintte henüz görev yok. Görevleri daha sonra Kapsam'dan veya Pano'dan ekleyebilirsiniz.")
                : (count == 1 ? "1 task will be included in this sprint." : "\(count) tasks will be included in this sprint.",
                   "Bu sprinte \(count) görev dahil edilecek.")
        case .completedOn(let date):
            ("Completed \(date)", "\(date) tarihinde tamamlandı")
        case .daysRemaining(let days):
            if days > 0 {
                (days == 1 ? "1 day remaining" : "\(days) days remaining", "\(days) gün kaldı")
            } else if days == 0 {
                ("Ends today", "Bugün bitiyor")
            } else {
                (days == -1 ? "1 day overdue" : "\(-days) days overdue", "\(-days) gün gecikti")
            }
        case .deleteSprintTitle(let name):
            ("Delete \(name)?", "\(name) silinsin mi?")
        case .deleteSprintMessage(let count):
            count == 0
                ? ("The sprint will be removed. It has no tasks.", "Sprint silinecek. İçinde görev yok.")
                : (count == 1
                    ? "The sprint will be removed. Its task will be moved to the Backlog."
                    : "The sprint will be removed. Its \(count) tasks will be moved to the Backlog.",
                   "Sprint silinecek. İçindeki \(count) görev İş Havuzu'na taşınacak.")

        // Complete sprint
        case .completedTasks: ("Completed tasks", "Tamamlanan görevler")
        case .openTasks: ("Open tasks", "Açık görevler")
        case .moveOpenTasksTo: ("Move open tasks to", "Açık görevleri taşı")
        case .keepInCompletedSprint: ("Keep in this sprint", "Bu sprintte bırak")
        case .openTasksFooter:
            ("Completed tasks always stay in the sprint with their final status.",
             "Tamamlanan görevler her zaman son durumlarıyla sprintte kalır.")
        case .completeSprintNote:
            ("Completed sprints stay in Scope for later review.",
             "Tamamlanan sprintler daha sonra incelemek için Kapsam'da kalır.")

        // Scope & Board
        case .searchTasks: ("Search tasks", "Görevlerde ara")
        case .noMatchingTasks: ("No tasks here match your search.", "Burada aramanızla eşleşen görev yok.")
        case .emptyBacklog:
            ("Your backlog is empty. Create a task or drag one here.",
             "İş havuzunuz boş. Bir görev oluşturun veya buraya sürükleyin.")
        case .emptySprintTitle: ("Plan your sprint", "Sprintinizi planlayın")
        case .emptySprintMessage:
            ("Drag tasks from the Backlog, or create new ones, to plan the work for this sprint.",
             "Bu sprintin işini planlamak için İş Havuzu'ndan görev sürükleyin veya yeni görev oluşturun.")
        case .completedSprintEmpty: ("This sprint has no tasks.", "Bu sprintte görev yok.")
        case .noActiveSprintTitle: ("No Active Sprint", "Aktif Sprint Yok")
        case .noActiveSprintMessage:
            ("Start a sprint on the Scope screen to see its tasks on the Board.",
             "Görevlerini Pano'da görmek için Kapsam ekranında bir sprint başlatın.")
        case .goToScope: ("Go to Scope", "Kapsam'a Git")
        case .tasksDone(let done, let total):
            ("\(done) of \(total) tasks done", "\(total) görevden \(done) tanesi tamamlandı")

        // Settings
        case .language: ("Language", "Dil")
        case .languageFooter:
            ("The interface switches immediately, and your choice is remembered next time.",
             "Arayüz hemen değişir ve seçiminiz bir sonraki açılışta hatırlanır.")
        case .appearance: ("Appearance", "Görünüm")
        case .appearanceSystem: ("System", "Sistem")
        case .appearanceLight: ("Light", "Açık")
        case .appearanceDark: ("Dark", "Koyu")
        case .data: ("Data", "Veriler")
        case .dataFooter:
            ("Everything is stored locally on this Mac. Nothing is sent over the internet.",
             "Her şey bu Mac'te yerel olarak saklanır. İnternet üzerinden hiçbir şey gönderilmez.")
        case .storedTasks: ("Tasks", "Görevler")
        case .storedSprints: ("Sprints", "Sprintler")
        case .storageLocation: ("Location", "Konum")
        case .showInFinder: ("Show in Finder", "Finder'da Göster")
        case .keyboardShortcuts: ("Keyboard Shortcuts", "Klavye Kısayolları")
        case .version: ("Version", "Sürüm")

        // Errors
        case .saveFailedTitle: ("Changes Couldn't Be Saved", "Değişiklikler Kaydedilemedi")
        case .saveFailedMessage(let message):
            ("Your last change couldn't be written to disk: \(message)",
             "Son değişikliğiniz diske yazılamadı: \(message)")
        case .storeErrorTitle: ("Your Data Couldn't Be Opened", "Verileriniz Açılamadı")
        case .storeErrorMessage:
            ("The database file was left untouched. Make a copy of it before trying again.",
             "Veritabanı dosyasına dokunulmadı. Tekrar denemeden önce bir kopyasını alın.")
        }
    }
}
