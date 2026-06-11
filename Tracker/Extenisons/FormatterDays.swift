//
//  FormatterDays.swift
//  Tracker
//
//  Created by Dinar Mukhlisov on 08.06.2026.
//

import Foundation

final class FormatterDays {
    private static let dateFormatter = DateFormatter()
    static let weekdays = Calendar.current.weekdaySymbols
    static func shortWeekday(at index: Int) -> String {
        dateFormatter.shortWeekdaySymbols[index]
    }
}

extension Date {
    var weekdayIndex: Int {
        Calendar.current.component(.weekday, from: self) - 1
    }
}

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}
