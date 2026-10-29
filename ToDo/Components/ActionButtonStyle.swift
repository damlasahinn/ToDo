//
//  ActionButtonStyle.swift
//  ToDo
//
//  Jira-style buttons for the main content area. Sheets and Settings use native buttons.
//

import SwiftUI

struct ActionButtonStyle: ButtonStyle {
    enum Kind {
        case primary
        case neutral
        case subtle
    }

    var kind: Kind

    func makeBody(configuration: Configuration) -> some View {
        ActionButtonBody(configuration: configuration, kind: kind)
    }
}

extension ButtonStyle where Self == ActionButtonStyle {
    static var primaryAction: ActionButtonStyle { ActionButtonStyle(kind: .primary) }
    static var neutralAction: ActionButtonStyle { ActionButtonStyle(kind: .neutral) }
    static var subtleAction: ActionButtonStyle { ActionButtonStyle(kind: .subtle) }
}

private struct ActionButtonBody: View {
    let configuration: ButtonStyleConfiguration
    let kind: ActionButtonStyle.Kind
    @Environment(\.isEnabled) private var isEnabled
    @State private var isHovered = false

    var body: some View {
        configuration.label
            .font(.system(size: 13, weight: .medium))
            .lineLimit(1)
            .foregroundStyle(foreground)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(background, in: RoundedRectangle(cornerRadius: 5, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
            .opacity(isEnabled ? 1 : 0.5)
            .onHover { isHovered = $0 && isEnabled }
    }

    private var foreground: Color {
        switch kind {
        case .primary: Theme.onBrand
        case .neutral: Theme.text
        case .subtle: Theme.textSubtle
        }
    }

    private var background: Color {
        let highlighted = isHovered || configuration.isPressed
        switch kind {
        case .primary: return highlighted ? Theme.brandHovered : Theme.brand
        case .neutral: return highlighted ? Theme.neutralHovered : Theme.neutral
        case .subtle: return highlighted ? Theme.neutral : .clear
        }
    }
}
