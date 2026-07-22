//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Dinar Mukhlisov on 21.07.2026.
//

import Foundation
import AppMetricaCore

protocol AnalyticsServiceProtocol {
    func report(_ event: AnalyticsEvent)
}

final class AnalyticsService: AnalyticsServiceProtocol {

    func report(_ event: AnalyticsEvent) {
        #if DEBUG
        print("[Analytics] \(event.parameters)")
        #endif

        AppMetrica.reportEvent(name: "ui_event", parameters: event.parameters) { error in
            print("Ошибка отправки события аналитики: \(error)")
        }
    }
}
