//
//  AppDelegate.swift
//  Tracker
//
//  Created by Dinar Mukhlisov on 28.05.2026.
//

import UIKit
import CoreData
import AppMetricaCore

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let coreDataManager = CoreDataManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if let configuration = AppMetricaConfiguration(apiKey: "e38fc50f-2f37-4f11-9719-199b67f4f464") {
            AppMetrica.activate(with: configuration)
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

