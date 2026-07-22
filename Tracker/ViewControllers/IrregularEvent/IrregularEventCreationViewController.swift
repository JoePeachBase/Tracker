//
//  UnRegularEventCreationViewController.swift
//  Tracker
//
//  Created by Dinar Mukhlisov on 09.06.2026.
//

import UIKit

final class IrregularEventCreationViewController: TrackerCreationBaseViewController {

    override var headerTitle: String { isEditingMode ? "edit.irregular.event".localized : "new.irregular.event".localized }
    override var tableViewHeight: CGFloat { 75 }
    override var scheduleForNewTracker: [WeekDay]? { nil }

    override func configureCell(_ cell: HabitTableViewCell, at indexPath: IndexPath) {
        cell.configure(title: "category".localized, subtitle: selectedCategory)
    }

    override func handleRowSelection(at indexPath: IndexPath) {
        let vc = HabitCategoryViewController(categoryStore: categoryStore, selectedCategory: selectedCategory)
        vc.onCategorySelected = { [weak self] title in
            guard let self else { return }
            self.selectedCategory = title
            self.trackersTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            self.updateCreateButtonState()
        }
        present(vc, animated: true)
    }
}


