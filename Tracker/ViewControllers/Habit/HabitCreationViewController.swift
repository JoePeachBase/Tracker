//
//  HabitCreationViewController.swift
//  Tracker
//
//  Created by Dinar Mukhlisov on 08.06.2026.
//

import UIKit

protocol TrackerActionProtocol {
    func add(tracker: Tracker, categoryTitle: String)
    func reload()
}

final class HabitCreationViewController: TrackerCreationBaseViewController {

    private var selectedDays: [WeekDay] = []

    override var headerTitle: String { "Новая привычка" }
    override var tableViewHeight: CGFloat { 150 }
    override var scheduleForNewTracker: [WeekDay]? { selectedDays }

    override func additionalCreateButtonValidation() -> Bool {
        !selectedDays.isEmpty
    }

    override func configureCell(_ cell: HabitTableViewCell, at indexPath: IndexPath) {
        switch HabitRow(rawValue: indexPath.row) {
        case .category:
            cell.configure(title: "Категория", subtitle: selectedCategory)
        case .schedule:
            let subtitle = selectedDays.isEmpty ? nil :
                selectedDays.sorted { $0.rawValue < $1.rawValue }
                    .map { $0.shortTitle }
                    .joined(separator: ", ")
            cell.configure(title: "Расписание", subtitle: subtitle)
        default:
            cell.configure(title: "Новая строка", subtitle: nil)
        }
    }

    override func handleRowSelection(at indexPath: IndexPath) {
        switch HabitRow(rawValue: indexPath.row) {
        case .schedule:
            let vc = HabitScheduleViewController()
            vc.selectedDays = selectedDays
            vc.onScheduleSelected = { [weak self] days in
                guard let self else { return }
                self.selectedDays = days
                self.trackersTableView.reloadRows(
                    at: [IndexPath(row: HabitRow.schedule.rawValue, section: 0)],
                    with: .none)
                self.updateCreateButtonState()
            }
            present(vc, animated: true)
            
        case .category:
            let vc = HabitCategoryViewController(categoryStore: categoryStore, selectedCategory: selectedCategory)
            vc.onCategorySelected = { [weak self] title in
                guard let self else { return }
                self.selectedCategory = title
                self.trackersTableView.reloadRows(
                    at: [IndexPath(row: HabitRow.category.rawValue, section: 0)],
                    with: .none)
                self.updateCreateButtonState()
            }
            present(vc, animated: true)
            
        default:
            break
        }
    }
}



