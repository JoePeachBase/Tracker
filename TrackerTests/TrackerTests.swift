//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Dinar Mukhlisov on 21.07.2026.
//

import XCTest
import SnapshotTesting
import CoreData
@testable import Tracker

final class TrackerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        isRecording = false
    }
    
    private func makeInMemoryContext() -> NSManagedObjectContext {
        let container = NSPersistentContainer(name: "Model")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Не удалось загрузить in-memory хранилище: \(error)")
            }
        }

        return container.viewContext
    }

    private func makeMainViewController() -> MainViewController {
        let context = makeInMemoryContext()

        let trackerStore = TrackerStore(context: context)
        let categoryStore = TrackerCategoryStore(context: context)
        let recordStore = TrackerRecordStore(context: context)
        let filterStore = FilterStore(context: context)
        let analyticsService = AnalyticsService()

        return MainViewController(
            trackerStore: trackerStore,
            categoryStore: categoryStore,
            recordStore: recordStore,
            filterStore: filterStore,
            analyticsService: analyticsService
        )
    }

    func testMainViewControllerLight() {
        let viewController = makeMainViewController()
        let navigationController = UINavigationController(rootViewController: viewController)

        assertSnapshot(
            of: navigationController,
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light))
        )
    }

    func testMainViewControllerDark() {
        let viewController = makeMainViewController()
        let navigationController = UINavigationController(rootViewController: viewController)

        assertSnapshot(
            of: navigationController,
            as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .dark))
        )
    }
}
