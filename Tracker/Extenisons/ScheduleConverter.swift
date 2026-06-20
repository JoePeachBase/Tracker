//
//  ScheduleConverter.swift
//  Tracker
//
//  Created by Dinar Mukhlisov on 20.06.2026.
//

import Foundation

class ScheduleConverter {
    func toString(_ weekDays: [WeekDay]) -> String {
        weekDays.map { String($0.rawValue) }.joined()
    }
    
    func toWeekDays(_ string: String) -> [WeekDay] {
        string.compactMap { char in
            guard let int = Int(String(char)) else { return nil }
            return WeekDay(rawValue: int)
        }
    }
}
