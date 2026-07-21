//
//  FilterStore.swift
//  Tracker
//
//  Created by Dinar Mukhlisov on 21.07.2026.
//

import Foundation
import CoreData

final class FilterStore {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    var currentFilter: TrackerFilter {
        get {
            guard let settings = fetchSettings(),
                  let filter = TrackerFilter(rawValue: Int(settings.selectedFilter))
            else { return .all }
            return filter
        }
        set {
            let settings = fetchSettings() ?? AppSettingsCoreData(context: context)
            settings.selectedFilter = Int16(newValue.rawValue)
            try? context.save()
        }
    }

    private func fetchSettings() -> AppSettingsCoreData? {
        let request = AppSettingsCoreData.fetchRequest()
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }
}
