//
//  String+Localized.swift
//  Tracker
//
//  Created by Dinar Mukhlisov on 16.07.2026.
//

import Foundation

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
