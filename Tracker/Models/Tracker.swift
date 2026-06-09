//
//  Tracker.swift
//  Tracker
//
//  Created by Dinar Mukhlisov on 08.06.2026.
//

import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let emoji: String
    let schedule: [WeekDay]?
    let color: UIColor
    let createdDate: Date
}
