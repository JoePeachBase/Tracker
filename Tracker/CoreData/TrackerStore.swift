//
//  TrackerStore.swift
//  Tracker
//
//  Created by Dinar Mukhlisov on 17.06.2026.
//

import Foundation
import CoreData

enum TrackerStoreError: Error {
    case decodingFailed
    case trackerNotFound
}

protocol TrackerStoreDelegate: AnyObject {
    func didUpdateTrackers()
}

final class TrackerStore: NSObject {
    
    weak var delegate: TrackerStoreDelegate?
    
    var trackers: [Tracker] {
        guard let objects = fetchedResultsController.fetchedObjects else { return [] }
        return objects.compactMap { try? makeTracker(from: $0) }
    }
    
    private let context:NSManagedObjectContext
    private let fetchedResultsController: NSFetchedResultsController<TrackerCoreData>
    private let scheduleConverter = ScheduleConverter()
    
    init(context: NSManagedObjectContext) {
        self.context = context
        
        let request = TrackerCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdDate", ascending: true)]
        
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
    
    func addTracker(_ tracker: Tracker, to category: TrackerCategoryCoreData) throws {
        let coreData = TrackerCoreData(context: context)
        coreData.id = tracker.id
        coreData.name = tracker.name
        coreData.emoji = tracker.emoji
        coreData.colorHex = ColorMarshalling.hexString(from: tracker.color)
        coreData.createdDate = tracker.createdDate
        coreData.schedule = tracker.schedule.map { scheduleConverter.toString($0)} as NSObject?
        coreData.category = category
        try context.save()
    }
    
    func updateTracker(_ tracker: Tracker, categoryTitle: String) throws {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        request.fetchLimit = 1
        
        guard let trackerCoreData = try context.fetch(request).first else {
            throw TrackerStoreError.trackerNotFound
        }
        
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.colorHex = ColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.schedule = tracker.schedule.map { scheduleConverter.toString($0) } as NSObject?
        
        if trackerCoreData.category?.title != categoryTitle {
            let categoryRequest = TrackerCategoryCoreData.fetchRequest()
            categoryRequest.predicate = NSPredicate(format: "title == %@", categoryTitle)
            categoryRequest.fetchLimit = 1
            trackerCoreData.category = try context.fetch(categoryRequest).first
        }
        
        try context.save()
    }
    
    func deleteTracker(_ tracker: Tracker) throws {
        guard let coreData = fetchedResultsController.fetchedObjects?.first(where: { $0.id == tracker.id }) else { return }
        context.delete(coreData)
        try context.save()
    }
    
    private func makeTracker(from coreData: TrackerCoreData) throws -> Tracker {
        guard let id = coreData.id,
              let name = coreData.name,
              let emoji = coreData.emoji,
              let colorHex = coreData.colorHex,
              let createdDate = coreData.createdDate
        else { throw TrackerStoreError.decodingFailed }
        
        let schedule = coreData.schedule.flatMap { $0 as? String }.map {
            scheduleConverter.toWeekDays($0)
        }
        
        return Tracker(id: id, name: name, emoji: emoji, schedule: schedule, color: ColorMarshalling.color(from: colorHex), createdDate: createdDate)
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            delegate?.didUpdateTrackers()
        }
}
