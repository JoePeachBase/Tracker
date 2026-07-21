//
//  MainViewController.swift
//  Tracker
//
//  Created by Dinar Mukhlisov on 08.06.2026.
//

import UIKit

final class MainViewController: UIViewController {
    
    private let trackerStore: TrackerStore
    private let categoryStore: TrackerCategoryStore
    private let recordStore: TrackerRecordStore
    private let filterStore: FilterStore
    private let analyticsService: AnalyticsServiceProtocol
    private var categories: [TrackerCategory] { categoryStore.categories }
    private var completedTrackers: Set<TrackerRecord>  {  recordStore.records }
    private var visibleCategories: [TrackerCategory] = []
    private var currentDate = Date()
    private var currentSearchText: String = ""
    private var dayCategories: [TrackerCategory] = []
    
    private var currentFilter: TrackerFilter {
        get { filterStore.currentFilter }
        set { filterStore.currentFilter = newValue }
    }
    
    private lazy var emptyScreenView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let emptyScreenImage = UIImageView()
        emptyScreenImage.translatesAutoresizingMaskIntoConstraints = false
        emptyScreenImage.image = .emptyScreen
        
        let emptyScreenText = UILabel()
        emptyScreenText.translatesAutoresizingMaskIntoConstraints = false
        emptyScreenText.text = "trackers.empty.screen.label".localized
        emptyScreenText.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        emptyScreenText.textColor = .ypBlack

        view.addSubview(emptyScreenImage)
        view.addSubview(emptyScreenText)
        
        NSLayoutConstraint.activate([
            emptyScreenImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyScreenImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyScreenText.topAnchor.constraint(equalTo: emptyScreenImage.bottomAnchor, constant: 8),
            emptyScreenText.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        return view
    }()
    
    private lazy var emptySearchScreenView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        
        let emptySearchScreenImage = UIImageView()
        emptySearchScreenImage.translatesAutoresizingMaskIntoConstraints = false
        emptySearchScreenImage.image = .emptySearchScreen
        
        let emptySearchScreenText = UILabel()
        emptySearchScreenText.translatesAutoresizingMaskIntoConstraints = false
        emptySearchScreenText.text = "nothing.found".localized
        emptySearchScreenText.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        emptySearchScreenText.textColor = .ypBlack

        view.addSubview(emptySearchScreenImage)
        view.addSubview(emptySearchScreenText)
        
        NSLayoutConstraint.activate([
            emptySearchScreenImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptySearchScreenImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptySearchScreenText.topAnchor.constraint(equalTo: emptySearchScreenImage.bottomAnchor, constant: 8),
            emptySearchScreenText.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        return view
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.backgroundColor = .ypWhiteNight
        picker.layer.cornerRadius = 8
        picker.clipsToBounds = true
        picker.overrideUserInterfaceStyle = .light
        picker.addTarget(self, action: #selector(datePickerButtonDidTapped), for: .valueChanged)
        return picker
    }()
    
    private lazy var datePickerButton: UIBarButtonItem = {
        UIBarButtonItem(customView: datePicker)
    }()
    
    private lazy var filtersButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("filters.button".localized, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypWhiteNight, for: .normal)
        button.backgroundColor = .ypBlue
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(filtersButtonDidTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .ypWhite
        return collectionView
    }()
    
    init(
        trackerStore: TrackerStore,
        categoryStore: TrackerCategoryStore,
        recordStore: TrackerRecordStore,
        filterStore: FilterStore,
        analyticsService: AnalyticsServiceProtocol
    ) {
        self.trackerStore = trackerStore
        self.categoryStore = categoryStore
        self.recordStore = recordStore
        self.filterStore = filterStore
        self.analyticsService = analyticsService
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        trackerStore.delegate = self
        categoryStore.delegate = self
        recordStore.delegate = self
        
        setupNavigationBar()
        setupLayoutAndConstraints()
        setupCollectionView()
        updateVisibleCategories()
        collectionView.reloadData()
        setupEmptyScreen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        analyticsService.report(AnalyticsEvent(event: .open, screen: "Main", item: nil))
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        analyticsService.report(AnalyticsEvent(event: .close, screen: "Main", item: nil))
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "trackerCell")
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsets(top: 24, left: 16, bottom: 24 + 66, right: 16) // +66 = высота кнопки (50) + отступ (16)
    }
    
    private func setupNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTrackerButtonDidTapped))
        addButton.tintColor = .ypBlack
        navigationBar.topItem?.setLeftBarButton(addButton, animated: true)
        
        navigationBar.topItem?.title = "trackers".localized
        navigationBar.prefersLargeTitles = true
        navigationBar.topItem?.largeTitleDisplayMode = .always
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        navigationBar.topItem?.searchController = searchController
        
        navigationBar.topItem?.setRightBarButton(datePickerButton, animated: true)
    }
    
    @objc
    private func filtersButtonDidTapped() {
        analyticsService.report(AnalyticsEvent(event: .click, screen: "Main", item: .filter))
        let vc = FiltersViewController(currentFilter: currentFilter)
        vc.onFilterSelected = { [weak self] filter in
            guard let self else { return }
            self.currentFilter = filter
            if filter == .today {
                self.currentDate = Date()
                self.datePicker.date = Date()
            }
            self.updateVisibleCategories(searchText: self.currentSearchText)
            self.collectionView.reloadData()
            self.setupEmptyScreen()
        }
        present(vc, animated: true)
    }
    
    @objc
    private func addTrackerButtonDidTapped() {
        analyticsService.report(AnalyticsEvent(event: .click, screen: "Main", item: .addTrack))
        let newTracker = TrackerCreationViewController(categoryStore: categoryStore)
        newTracker.trackersViewController = self
        present(newTracker, animated: true)
    }
    
    @objc
    private func datePickerButtonDidTapped(_ sender: UIDatePicker) {
        currentDate = sender.date
        updateVisibleCategories()
        collectionView.reloadData()
        setupEmptyScreen()
    }
    
    private func setupLayoutAndConstraints() {
        view.addSubview(collectionView)
        view.addSubview(emptyScreenView)
        view.addSubview(emptySearchScreenView)
        view.addSubview(filtersButton)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyScreenView.topAnchor.constraint(equalTo: view.topAnchor),
            emptyScreenView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            emptyScreenView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyScreenView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            emptySearchScreenView.topAnchor.constraint(equalTo: view.topAnchor),
            emptySearchScreenView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            emptySearchScreenView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptySearchScreenView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filtersButton.widthAnchor.constraint(equalToConstant: 114),
            filtersButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupEmptyScreen() {
        let hasVisibleItems = !visibleCategories.isEmpty
        let hasDayItems = hasTrackersForCurrentDate()

        if hasVisibleItems {
            // есть трекеры — показываем коллекцию
            collectionView.isHidden = false
            emptyScreenView.isHidden = true
            emptySearchScreenView.isHidden = true
        } else if hasDayItems {
            // на день трекеры есть, но поиск/фильтр ничего не оставил — заглушка "ничего не найдено"
            collectionView.isHidden = true
            emptyScreenView.isHidden = true
            emptySearchScreenView.isHidden = false
        } else {
            // на день трекеров вообще нет — стандартная заглушка
            collectionView.isHidden = true
            emptyScreenView.isHidden = false
            emptySearchScreenView.isHidden = true
        }

        filtersButton.isHidden = !hasTrackersForCurrentDate()
    }
    
    private func updateVisibleCategories(searchText: String = "") {
        let calendar = Calendar.current
        let weekdayIndex = calendar.component(.weekday, from: currentDate)

        guard let weekDay = WeekDay(calendarWeekday: weekdayIndex) else {
            dayCategories = []
            visibleCategories = []
            return
        }

        dayCategories = categories.compactMap { category in
            let filtered = category.trackers.filter {
                let matchesDay: Bool
                if let schedule = $0.schedule {
                    matchesDay = searchText.isEmpty ? schedule.contains(weekDay) : true
                } else {
                    matchesDay = searchText.isEmpty
                    ? calendar.isDate($0.createdDate, inSameDayAs: currentDate)
                    : true
                }
                let matchesSearch = searchText.isEmpty || $0.name.lowercased().contains(searchText.lowercased())
                return matchesDay && matchesSearch
            }
            return filtered.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filtered)
        }

        visibleCategories = applyStatusFilter(to: dayCategories)
    }
    
    private func applyStatusFilter(to categories: [TrackerCategory]) -> [TrackerCategory] {
        switch currentFilter {
        case .all, .today:
            return categories
        case .completed, .uncompleted:
            return categories.compactMap { category in
                let filtered = category.trackers.filter { tracker in
                    let isCompleted = completedTrackers.contains {
                        $0.trackerId == tracker.id &&
                        Calendar.current.isDate($0.date, inSameDayAs: currentDate.startOfDay)
                    }
                    return currentFilter == .completed ? isCompleted : !isCompleted
                }
                return filtered.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filtered)
            }
        }
    }
    
    private func hasTrackersForCurrentDate() -> Bool {
        let calendar = Calendar.current
        let weekdayIndex = calendar.component(.weekday, from: currentDate)
        guard let weekDay = WeekDay(calendarWeekday: weekdayIndex) else { return false }

        return categories.contains { category in
            category.trackers.contains { tracker in
                if let schedule = tracker.schedule {
                    return schedule.contains(weekDay)
                } else {
                    return calendar.isDate(tracker.createdDate, inSameDayAs: currentDate)
                }
            }
        }
    }
}

extension MainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        currentSearchText = searchController.searchBar.text ?? ""
        updateVisibleCategories(searchText: currentSearchText)
        collectionView.reloadData()
        setupEmptyScreen()
    }
}

extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? SupplementaryView else { return UICollectionReusableView()}
        view.titleLabel.text = visibleCategories[indexPath.section].title
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint
    ) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(actionProvider: { [weak self] _ in
            guard let self else { return nil }
            let tracker = self.visibleCategories[indexPath.section].trackers[indexPath.row]
            
            let edit = UIAction(title: "edit".localized) { _ in
                self.analyticsService.report(AnalyticsEvent(event: .click, screen: "Main", item: .edit))
                self.editTracker(tracker)
            }
            let delete = UIAction(title: "delete".localized, attributes: .destructive) { _ in
                self.analyticsService.report(AnalyticsEvent(event: .click, screen: "Main", item: .delete))
                self.confirmDelete(tracker)
            }
            return UIMenu(children: [edit, delete])
        })
    }
    
    private func editTracker(_ tracker: Tracker) {
        let categoryTitle = categoryStore.categories
            .first { $0.trackers.contains { $0.id == tracker.id } }?
            .title
        
        let vc: TrackerCreationBaseViewController
        if tracker.schedule != nil {
            vc = HabitCreationViewController(
                categoryStore: categoryStore,
                editingTracker: tracker,
                editingCategoryTitle: categoryTitle
            )
        } else {
            vc = IrregularEventCreationViewController(
                categoryStore: categoryStore,
                editingTracker: tracker,
                editingCategoryTitle: categoryTitle
            )
        }
        vc.trackersViewController = self
        present(vc, animated: true)
    }
    
    private func confirmDelete(_ tracker: Tracker) {
        let alert = UIAlertController(
            title: nil,
            message: "tracker.not.needed".localized,
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: "delete".localized, style: .destructive) { [weak self] _ in
            guard let self else { return }
            do {
                try self.trackerStore.deleteTracker(tracker)
            } catch {
                print("Ошибка удаления трекера: \(error)")
            }
        })
        alert.addAction(UIAlertAction(title: "cancel.button".localized, style: .cancel))
        present(alert, animated: true)
    }
}

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trackerCell", for: indexPath) as? TrackerCollectionViewCell else { return UICollectionViewCell()}
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        let isCompleted = completedTrackers.contains {
            $0.trackerId == tracker.id &&
            Calendar.current.isDate($0.date, inSameDayAs: currentDate.startOfDay)
        }
        let daysCount = completedTrackers.filter { $0.trackerId == tracker.id }.count
        cell.configure(tracker: tracker, isCompleted: isCompleted, daysCount: daysCount)
        cell.onCounterTaped = { [weak self] in
            guard let self, currentDate.startOfDay <= Date().startOfDay else { return }
            self.analyticsService.report(AnalyticsEvent(event: .click, screen: "Main", item: .track))
            
            let isNowCompleted = completedTrackers.contains {
                $0.trackerId == tracker.id &&
                Calendar.current.isDate($0.date, inSameDayAs: self.currentDate.startOfDay)
            }
            
            do {
                let record = TrackerRecord(trackerId: tracker.id, date: currentDate.startOfDay)
                if isNowCompleted {
                    try recordStore.deleteRecord(record)
                } else {
                    try recordStore.addRecord(record)
                }
                collectionView.reloadItems(at: [indexPath])
            } catch {
                print("Ошибка обновления записи: \(error)")
            }
            
        }
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }
}

extension MainViewController: TrackerActionProtocol {
    func add(tracker: Tracker, categoryTitle: String) {
        do {
            if categoryStore.categoryCoreData(with: categoryTitle) == nil {
                try categoryStore.addCategory(TrackerCategory(title: categoryTitle, trackers: []))
            }
            guard let categoryCoreData = categoryStore.categoryCoreData(with: categoryTitle) else { return }
            try trackerStore.addTracker(tracker, to: categoryCoreData)
        } catch {
            print("Ошибка сохранения трекера: \(error)")
        }
    }
    
    func update(tracker: Tracker, categoryTitle: String) {
        do {
            try trackerStore.updateTracker(tracker, categoryTitle: categoryTitle)
        } catch {
            print("Ошибка обновления трекера: \(error)")
        }
    }
    
    func reload() {
        updateVisibleCategories()
        self.collectionView.reloadData()
        setupEmptyScreen()
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: (collectionView.bounds.width - 16 * 2 - 9) / 2, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 10, left: 0, bottom: 16, right: 0)
    }
}

extension MainViewController: TrackerStoreDelegate {
    func didUpdateTrackers() {
        updateVisibleCategories()
        collectionView.reloadData()
        setupEmptyScreen()
    }
}

extension MainViewController: TrackerCategoryStoreDelegate {
    func didUpdateCategories() {
        updateVisibleCategories()
        collectionView.reloadData()
        setupEmptyScreen()
    }
}

extension MainViewController: TrackerRecordStoreDelegate {
    func didUpdateRecords() {
        updateVisibleCategories()
        collectionView.reloadData()
        setupEmptyScreen()
    }
}
