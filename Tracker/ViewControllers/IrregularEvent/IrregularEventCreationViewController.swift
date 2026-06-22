//
//  UnRegularEventCreationViewController.swift
//  Tracker
//
//  Created by Dinar Mukhlisov on 09.06.2026.
//

import UIKit

final class IrregularEventCreationViewController: TrackerCreationBaseViewController {

    override var headerTitle: String { "Новое нерегулярное событие" }
    override var tableViewHeight: CGFloat { 75 }
    override var scheduleForNewTracker: [WeekDay]? { nil }

    override func configureCell(_ cell: HabitTableViewCell, at indexPath: IndexPath) {
        cell.configure(title: "Категория", subtitle: selectedCategory)
    }

    override func handleRowSelection(at indexPath: IndexPath) {
        // TODO: - Category
    }
}


