//
//  TrackerRecordCoreData+CoreDataProperties.swift
//  Tracker
//
//  Created by Dinar Mukhlisov on 16.06.2026.
//
//

import Foundation
import CoreData


extension TrackerRecordCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerRecordCoreData> {
        return NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
    }

    @NSManaged public var date: Date?
    @NSManaged public var trackerId: UUID?
    @NSManaged public var tracker: TrackerCoreData?

}

extension TrackerRecordCoreData : Identifiable {

}
