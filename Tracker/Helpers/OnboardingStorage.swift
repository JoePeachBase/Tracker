//
//  OnboardingStorage.swift
//  Tracker
//
//  Created by Dinar Mukhlisov on 13.07.2026.
//

import Foundation

enum OnboardingStorage {
    private static let key = "hasSeenOnboarding"
    static var hasSeenOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}
