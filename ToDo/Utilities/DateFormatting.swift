//
//  DateFormatting.swift
//  ToDo
//

import Foundation

nonisolated enum DateFormatting {
    /// "29 Oct – 12 Nov", adding the year only when the range is not in the current year.
    static func range(from start: Date, to end: Date, locale: Locale) -> String {
        let calendar = Calendar.current
        let showsYear = !calendar.isDate(start, equalTo: .now, toGranularity: .year)
            || !calendar.isDate(end, equalTo: .now, toGranularity: .year)
        var style = Date.FormatStyle(locale: locale).day().month(.abbreviated)
        if showsYear {
            style = style.year()
        }
        return "\(start.formatted(style)) – \(end.formatted(style))"
    }

    static func medium(_ date: Date, locale: Locale, includingTime: Bool = false) -> String {
        date.formatted(Date.FormatStyle(date: .abbreviated, time: includingTime ? .shortened : .omitted, locale: locale))
    }

    /// Whole days from today until `date` (negative when it is in the past).
    static func daysFromToday(to date: Date) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        return calendar.dateComponents([.day], from: today, to: calendar.startOfDay(for: date)).day ?? 0
    }
}
