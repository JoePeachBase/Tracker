//
//  AnalyticsEvent.swift
//  Tracker
//
//  Created by Dinar Mukhlisov on 21.07.2026.
//

import Foundation

enum AnalyticsEventType: String {
    case open
    case close
    case click
}

enum AnalyticsItem: String {
    case addTrack = "add_track"
    case track
    case filter
    case edit
    case delete
}

struct AnalyticsEvent {
    let event: AnalyticsEventType
    let screen: String
    let item: AnalyticsItem?

    var parameters: [AnyHashable: Any] {
        var params: [AnyHashable: Any] = [
            "event": event.rawValue,
            "screen": screen
        ]
        if let item {
            params["item"] = item.rawValue
        }
        return params
    }
}
