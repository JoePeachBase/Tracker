//
//  Int+Localized.swift
//  Tracker
//
//  Created by Dinar Mukhlisov on 16.07.2026.
//

import Foundation

extension Int {
    func localizeNumbers(_ key: String) -> String {
        let localizedFormat = NSLocalizedString(key, tableName: nil, bundle: .main, comment: "")
        return String.localizedStringWithFormat(localizedFormat, self)
    }
}
