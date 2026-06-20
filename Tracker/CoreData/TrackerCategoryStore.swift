//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Dinar Mukhlisov on 17.06.2026.
//

import Foundation
import CoreData

enum TrackerCategoryStoreError: Error {
    case decodingFailed
}

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdateCategories()
}

final class TrackerCategoryStore: NSObject {
    
    weak var delegate: TrackerCategoryStoreDelegate?
    
    var categories: [TrackerCategory] {
        guard let objects = fetchedResultsController.fetchedObjects else { return [] }
        return objects.compactMap { try? makeCategory(from: $0) }
    }
    
    private let context: NSManagedObjectContext
    private let fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>
    private let colorMarshalling = ColorMarshalling()
    
    init(context: NSManagedObjectContext) {
        self.context = context
        
        let request = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
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
    
    func addCategory(_ category: TrackerCategory) throws {
        let coreData = TrackerCategoryCoreData(context: context)
        coreData.title = category.title
        try context.save()
    }
    
    func categoryCoreData(with title: String) -> TrackerCategoryCoreData? {
        fetchedResultsController.fetchedObjects?.first { $0.title == title}
    }
    
    private func makeCategory(from coreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let title = coreData.title else { throw TrackerCategoryStoreError.decodingFailed }
        
        let trackers = (coreData.trackers as? Set<TrackerCoreData>)?.compactMap { trackerCoreData -> Tracker? in
            guard let id = trackerCoreData.id,
                  let name = trackerCoreData.name,
                  let emoji = trackerCoreData.emoji,
                  let colorHex = trackerCoreData.colorHex,
                  let createdDate = trackerCoreData.createdDate
            else { return nil }
            
            let schedule = (trackerCoreData.schedule as? String).map {
                ScheduleConverter().toWeekDays($0)
            }
            
            return Tracker(
                id: id,
                name: name,
                emoji: emoji,
                schedule: schedule,
                color: colorMarshalling.color(from: colorHex),
                createdDate: createdDate
            )
        } ?? []
        
        return TrackerCategory(title: title, trackers: trackers)
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            delegate?.didUpdateCategories()
        }
}
