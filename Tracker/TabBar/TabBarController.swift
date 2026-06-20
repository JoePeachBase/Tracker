//
//  TabBarController.swift
//  Tracker
//
//  Created by Dinar Mukhlisov on 08.06.2026.
//

import UIKit

final class TabBarController: UITabBarController {
    
    private let coreDataManager: CoreDataManager
    
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    private func setupTabBar() {
        let context = coreDataManager.persistentContainer.viewContext
        
        let trackerStore = TrackerStore(context: context)
        let categoryStore = TrackerCategoryStore(context: context)
        let recordStore = TrackerRecordStore(context: context)
        
        
        let vc = MainViewController(
            trackerStore: trackerStore,
            categoryStore: categoryStore,
            recordStore: recordStore
        )
        
        let trackers = UINavigationController(rootViewController: vc)
        trackers.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: .trackers,
            selectedImage: nil
        )
        
        let statisticViewController = StatisticViewController()
        statisticViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: .statistics,
            selectedImage: nil
        )
        
        viewControllers = [trackers, statisticViewController]
    }
}
