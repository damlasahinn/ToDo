//
//  Theme.swift
//  ToDo
//
//  Colors modelled on Atlassian's design tokens. Every color has a light and a dark
//  variant and resolves automatically for the current appearance.
//

import AppKit
import SwiftUI

nonisolated enum Theme {
    // Surfaces
    static let surface = Color(light: 0xFFFFFF, dark: 0x1D2125)
    static let sunken = Color(light: 0xF7F8F9, dark: 0x161A1D)
    static let raised = Color(light: 0xFFFFFF, dark: 0x22272B)
    static let raisedHovered = Color(light: 0xF1F2F4, dark: 0x282E33)
    static let border = Color(light: 0x091E42, lightOpacity: 0.14, dark: 0xA6C5E2, darkOpacity: 0.16)
    static let dropHighlight = Color(light: 0xE9F2FF, dark: 0x1C2B41)

    // Text
    static let text = Color(light: 0x172B4D, dark: 0xB6C2CF)
    static let textSubtle = Color(light: 0x44546F, dark: 0x9FADBC)
    static let textSubtlest = Color(light: 0x626F86, dark: 0x8C9BAB)

    // Brand & controls
    static let brand = Color(light: 0x0C66E4, dark: 0x579DFF)
    static let brandHovered = Color(light: 0x0055CC, dark: 0x85B8FF)
    static let onBrand = Color(light: 0xFFFFFF, dark: 0x1D2125)
    static let neutral = Color(light: 0x091E42, lightOpacity: 0.06, dark: 0xA1BDD9, darkOpacity: 0.08)
    static let neutralHovered = Color(light: 0x091E42, lightOpacity: 0.12, dark: 0xA6C5E2, darkOpacity: 0.16)
    static let taskIcon = Color(light: 0x4BADE8, dark: 0x4BADE8)
    static let danger = Color(light: 0xC9372C, dark: 0xF87168)

    static func lozengeBackground(_ status: TaskStatus) -> Color {
        switch status {
        case .todo: Color(light: 0x091E42, lightOpacity: 0.08, dark: 0xA1BDD9, darkOpacity: 0.14)
        case .inProgress: Color(light: 0xE9F2FF, dark: 0x09326C)
        case .test: Color(light: 0xF3F0FF, dark: 0x352C63)
        case .done: Color(light: 0xDCFFF1, dark: 0x164B35)
        }
    }

    static func lozengeForeground(_ status: TaskStatus) -> Color {
        switch status {
        case .todo: Color(light: 0x44546F, dark: 0x9FADBC)
        case .inProgress: Color(light: 0x0055CC, dark: 0x85B8FF)
        case .test: Color(light: 0x5E4DB2, dark: 0xB8ACF6)
        case .done: Color(light: 0x216E4E, dark: 0x7EE2B8)
        }
    }

    /// Solid accent used for dots and progress indicators.
    static func accent(_ status: TaskStatus) -> Color {
        switch status {
        case .todo: Color(light: 0x8590A2, dark: 0x8C9BAB)
        case .inProgress: Color(light: 0x1D7AFC, dark: 0x579DFF)
        case .test: Color(light: 0x8270DB, dark: 0x9F8FEF)
        case .done: Color(light: 0x22A06B, dark: 0x4BCE97)
        }
    }

    static func priorityColor(_ priority: TaskPriority) -> Color {
        switch priority {
        case .high: Color(light: 0xC9372C, dark: 0xF87168)
        case .medium: Color(light: 0xE56910, dark: 0xFEA362)
        case .low: Color(light: 0x0C66E4, dark: 0x579DFF)
        }
    }
}

extension Color {
    /// A color that switches between two sRGB hex values with the appearance.
    nonisolated init(light: UInt32, lightOpacity: Double = 1, dark: UInt32, darkOpacity: Double = 1) {
        self.init(nsColor: NSColor(name: nil) { appearance in
            let isDark = appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
            return isDark ? NSColor(hex: dark, alpha: darkOpacity) : NSColor(hex: light, alpha: lightOpacity)
        })
    }
}

extension NSColor {
    nonisolated convenience init(hex: UInt32, alpha: Double = 1) {
        self.init(
            srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha
        )
    }
}
