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
    private var categories: [TrackerCategory] { categoryStore.categories }
    private var completedTrackers: Set<TrackerRecord>  {  recordStore.records }
    private var visibleCategories: [TrackerCategory] = []
    private var currentDate = Date()
    private var currentSearchText: String = ""
    
    private lazy var emptyScreenView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let emptyScreenImage = UIImageView()
        emptyScreenImage.translatesAutoresizingMaskIntoConstraints = false
        emptyScreenImage.image = .emptyScreen
        
        let emptyScreenText = UILabel()
        emptyScreenText.translatesAutoresizingMaskIntoConstraints = false
        emptyScreenText.text = "Что будем отслеживать?"
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
        emptySearchScreenText.text = "Ничего не найдено"
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
    
    private lazy var datePickerButton: UIBarButtonItem = {
        let datePickerButton = UIDatePicker()
        datePickerButton.datePickerMode = .date
        datePickerButton.preferredDatePickerStyle = .compact
        datePickerButton.addTarget(self, action: #selector(datePickerButtonDidTapped), for: .valueChanged)
        let button = UIBarButtonItem(customView: datePickerButton)
        return button
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    init(trackerStore: TrackerStore, categoryStore: TrackerCategoryStore, recordStore: TrackerRecordStore) {
        self.trackerStore = trackerStore
        self.categoryStore = categoryStore
        self.recordStore = recordStore
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "trackerCell")
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.contentInset = UIEdgeInsets(top: 24, left: 16, bottom: 24, right: 16)
    }
    
    private func setupNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTrackerButtonDidTapped))
        addButton.tintColor = .ypBlack
        navigationBar.topItem?.setLeftBarButton(addButton, animated: true)
        
        navigationBar.topItem?.title = "Трекеры"
        navigationBar.prefersLargeTitles = true
        navigationBar.topItem?.largeTitleDisplayMode = .always
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        navigationBar.topItem?.searchController = searchController
        
        navigationBar.topItem?.setRightBarButton(datePickerButton, animated: true)
    }
    
    @objc
    private func addTrackerButtonDidTapped() {
        let newTracker = TrackerCreationViewController() /*HabitCreationViewController()*/
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
            emptySearchScreenView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupEmptyScreen() {
        let isSearchActive = !currentSearchText.isEmpty
        let hasVisibleItems = !visibleCategories.isEmpty

        if hasVisibleItems {
            // есть трекеры — показываем коллекцию
            collectionView.isHidden = false
            emptyScreenView.isHidden = true
            emptySearchScreenView.isHidden = true
        } else if isSearchActive {
            // поиск без результатов — заглушка поиска
            collectionView.isHidden = true
            emptyScreenView.isHidden = true
            emptySearchScreenView.isHidden = false
        } else {
            // нет трекеров вообще — стандартная заглушка
            collectionView.isHidden = true
            emptyScreenView.isHidden = false
            emptySearchScreenView.isHidden = true
        }
    }
    
    private func updateVisibleCategories(searchText: String = "") {
        let calendar = Calendar.current
        let weekdayIndex = calendar.component(.weekday, from: currentDate)
        
        guard let weekDay = WeekDay(calendarWeekday: weekdayIndex) else {
            return
        }
        visibleCategories = categories.compactMap { category in
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
    func add(tracker: Tracker) {
        let categoryTitle = "Домашний уют" // позже заменим на выбор пользователя
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
