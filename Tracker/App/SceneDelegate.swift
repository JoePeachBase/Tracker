//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Dinar Mukhlisov on 28.05.2026.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        let userDefaults = UserDefaults.standard
        let isFirstAppStart = !OnboardingStorage.hasSeenOnboarding
        
        if isFirstAppStart {
            window?.rootViewController = OnboardingViewController(coreDataManager: appDelegate.coreDataManager)
        } else {
            window?.rootViewController = TabBarController(coreDataManager: appDelegate.coreDataManager)
        }
        
        window?.windowScene = windowScene
        window?.makeKeyAndVisible()
    }
}

