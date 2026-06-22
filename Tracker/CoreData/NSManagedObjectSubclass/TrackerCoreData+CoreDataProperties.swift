//
//  TrackerCoreData+CoreDataProperties.swift
//  Tracker
//
//  Created by Dinar Mukhlisov on 16.06.2026.
//
//

import Foundation
import CoreData


extension TrackerCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerCoreData> {
        return NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
    }

    @NSManaged public var colorHex: String?
    @NSManaged public var createdDate: Date?
    @NSManaged public var emoji: String?
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var schedule: NSObject?
    @NSManaged public var category: TrackerCategoryCoreData?
    @NSManaged public var records: NSSet?

}

// MARK: Generated accessors for records
extension TrackerCoreData {

    @objc(addRecordsObject:)
    @NSManaged public func addToRecords(_ value: TrackerRecordCoreData)

    @objc(removeRecordsObject:)
    @NSManaged public func removeFromRecords(_ value: TrackerRecordCoreData)

    @objc(addRecords:)
    @NSManaged public func addToRecords(_ values: NSSet)

    @objc(removeRecords:)
    @NSManaged public func removeFromRecords(_ values: NSSet)

}

extension TrackerCoreData : Identifiable {

}
