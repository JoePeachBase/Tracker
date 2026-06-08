//
//  TabBarController.swift
//  Tracker
//
//  Created by Dinar Mukhlisov on 08.06.2026.
//

import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    private func setupTabBar() {
        let vc = MainViewController()
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
