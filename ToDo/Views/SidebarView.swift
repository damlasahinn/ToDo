//
//  SidebarView.swift
//  ToDo
//

import SwiftData
import SwiftUI

struct SidebarView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.localizer) private var t
    @Query(sort: \Sprint.createdAt) private var sprints: [Sprint]

    private var activeSprint: Sprint? {
        sprints.first { $0.state == .active }
    }

    var body: some View {
        List(selection: Binding(
            get: { router.selection },
            set: { if let item = $0 { router.selection = item } }
        )) {
            Section(t(.planning)) {
                ForEach([SidebarItem.scope, .board]) { item in
                    Label(t(item.label), systemImage: item.systemImage)
                        .tag(item)
                }
            }
            Section {
                Label(t(SidebarItem.settings.label), systemImage: SidebarItem.settings.systemImage)
                    .tag(SidebarItem.settings)
            }
        }
        .listStyle(.sidebar)
        .safeAreaInset(edge: .top, spacing: 0) {
            projectHeader
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if let activeSprint {
                activeSprintFooter(activeSprint)
            }
        }
    }

    private var projectHeader: some View {
        HStack(spacing: 10) {
            Image(systemName: "checklist")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(
                    LinearGradient(colors: [Color(light: 0x1D7AFC, dark: 0x1D7AFC), Color(light: 0x8270DB, dark: 0x8270DB)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: RoundedRectangle(cornerRadius: 8, style: .continuous)
                )
            VStack(alignment: .leading, spacing: 1) {
                Text("ToDo")
                    .font(.system(size: 13, weight: .semibold))
                Text(t(.personalProject))
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private func activeSprintFooter(_ sprint: Sprint) -> some View {
        Button {
            router.selection = .board
        } label: {
            VStack(alignment: .leading, spacing: 3) {
                Text(t.uppercased(.activeSprint))
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
                Text(sprint.name)
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(1)
                Text(t(.daysRemaining(DateFormatting.daysFromToday(to: sprint.endDate))))
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
        .padding(12)
    }
}
