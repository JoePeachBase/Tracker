//
//  TrackerFilter.swift
//  Tracker
//
//  Created by Dinar Mukhlisov on 21.07.2026.
//

import Foundation

enum TrackerFilter: Int, CaseIterable {
    case all
    case today
    case completed
    case uncompleted

    var title: String {
        switch self {
        case .all: return "filter.all".localized
        case .today: return "filter.today".localized
        case .completed: return "filter.completed".localized
        case .uncompleted: return "filter.uncompleted".localized
        }
    }

    /// Показывать ли галочку в списке фильтров — у "Все трекеры" и "Трекеры на сегодня" галочки не бывает
    var isCheckable: Bool {
        self == .completed || self == .uncompleted
    }
}
