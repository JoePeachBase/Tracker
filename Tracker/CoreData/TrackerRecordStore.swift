//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Dinar Mukhlisov on 17.06.2026.
//

import Foundation
import CoreData

enum TrackerRecordStoreError: Error {
    case decodingFailed
}

protocol TrackerRecordStoreDelegate: AnyObject {
    func didUpdateRecords()
}

final class TrackerRecordStore: NSObject {
    
    weak var delegate: TrackerRecordStoreDelegate?
    
    var records: Set<TrackerRecord> {
        guard let objects = fetchedResultsController.fetchedObjects else { return [] }
        return Set(objects.compactMap { try? makeRecord(from: $0) })
    }
    
    private let context: NSManagedObjectContext
    private let fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>
    
    init(context: NSManagedObjectContext) {
        self.context = context
        
        let request = TrackerRecordCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        super.init()
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
    }
    
    func addRecord(_ record: TrackerRecord) throws {
        let cd = TrackerRecordCoreData(context: context)
        cd.trackerId = record.trackerId
        cd.date = record.date
        try context.save()
    }
    
    func deleteRecord(_ record: TrackerRecord) throws {
        guard let cd = fetchedResultsController.fetchedObjects?.first(where: {
            $0.trackerId == record.trackerId &&
            Calendar.current.isDate($0.date ?? .distantPast, inSameDayAs: record.date)
        }) else { return }
        context.delete(cd)
        try context.save()
    }
    
    private func makeRecord(from cd: TrackerRecordCoreData) throws -> TrackerRecord {
        guard
            let trackerId = cd.trackerId,
            let date = cd.date
        else { throw TrackerRecordStoreError.decodingFailed }
        
        return TrackerRecord(trackerId: trackerId, date: date)
    }
}

extension Notification.Name {
    static let trackerRecordsDidChange = Notification.Name("trackerRecordsDidChange")
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateRecords()
        NotificationCenter.default.post(name: .trackerRecordsDidChange, object: nil)
    }
}
