//
//  CategoryListViewModel.swift
//  Tracker
//
//  Created by Dinar Mukhlisov on 07.07.2026.
//

import Foundation

struct CategoryCellViewModel {
    let title: String
    let isSelected: Bool
}

final class CategoryListViewModel {

    var onCategoriesChanged: (() -> Void)?
    var onCategorySelected: ((String) -> Void)?
    var onError: ((Error) -> Void)?

    private(set) var cellViewModels: [CategoryCellViewModel] = [] {
        didSet { onCategoriesChanged?() }
    }

    private let store: TrackerCategoryStore
    private var selectedTitle: String?

    init(store: TrackerCategoryStore, selectedTitle: String?) {
        self.store = store
        self.selectedTitle = selectedTitle
        self.store.delegate = self
        reloadCellViewModels()
    }

    var isEmpty: Bool { cellViewModels.isEmpty }

    func didSelectCategory(at index: Int) {
        guard index < cellViewModels.count else { return }
        let title = cellViewModels[index].title
        selectedTitle = title
        reloadCellViewModels()
        onCategorySelected?(title)
    }

    func addCategory(title: String) {
        do {
            try store.addCategory(TrackerCategory(title: title, trackers: []))
        } catch {
            onError?(error)
        }
    }

    func renameCategory(at index: Int, newTitle: String) {
        guard index < cellViewModels.count else { return }
        let oldTitle = cellViewModels[index].title
        do {
            try store.renameCategory(from: oldTitle, to: newTitle)
            if selectedTitle == oldTitle { selectedTitle = newTitle }
        } catch {
            onError?(error)
        }
    }

    func deleteCategory(at index: Int) {
        guard index < cellViewModels.count else { return }
        let title = cellViewModels[index].title
        do {
            try store.deleteCategory(TrackerCategory(title: title, trackers: []))
        } catch {
            onError?(error)
        }
    }

    private func reloadCellViewModels() {
        cellViewModels = store.categories.map {
            CategoryCellViewModel(title: $0.title, isSelected: $0.title == selectedTitle)
        }
    }
}

extension CategoryListViewModel: TrackerCategoryStoreDelegate {
    func didUpdateCategories() {
        reloadCellViewModels()
    }
}
