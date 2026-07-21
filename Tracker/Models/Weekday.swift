//
//  Weekday.swift
//  Tracker
//
//  Created by Dinar Mukhlisov on 08.06.2026.
//

import Foundation

enum WeekDay: Int, CaseIterable {
    case monday = 1
    case tuesday = 2
    case wednesday = 3
    case thursday = 4
    case friday = 5
    case saturday = 6
    case sunday = 7
    
    var name: String {
        switch self {
        case .monday:
            "weekdays.monday".localized
        case .tuesday:
            "weekdays.tuesday".localized
        case .wednesday:
            "weekdays.wednesday".localized
        case .thursday:
            "weekdays.thursday".localized
        case .friday:
            "weekdays.friday".localized
        case .saturday:
            "weekdays.saturday".localized
        case .sunday:
            "weekdays.sunday".localized
        }
    }
    
    var shortTitle: String {
        switch self {
        case .monday: "weekdays.mon".localized
        case .tuesday: "weekdays.tue".localized
        case .wednesday: "weekdays.wed".localized
        case .thursday: "weekdays.thu".localized
        case .friday: "weekdays.fri".localized
        case .saturday: "weekdays.sat".localized
        case .sunday: "weekdays.sun".localized
        }
    }
}

extension WeekDay {
    init?(calendarWeekday: Int) {
        let normalized = calendarWeekday == 1 ? 7 : calendarWeekday - 1
        self.init(rawValue: normalized)
    }
}
