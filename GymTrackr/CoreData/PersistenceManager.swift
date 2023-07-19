//
//  CoreDataManager.swift
//  GymTrackr
//
//  Created by Sadık Kemal Sarı on 19.07.2023.
//

import CoreData
import UIKit

// MARK: - PersistenceManager
final class PersistenceManager {

    // MARK: Internal
    static let shared: PersistenceManager = .init()
    static var newInMemory: PersistenceManager { .init(storeType: .inMemory) }
    var mainContext: NSManagedObjectContext { persistentContainer.viewContext }

    // MARK: Private
    private let persistentContainer: NSPersistentContainer

    // MARK: Lifecycle
    private init(storeType: StoreType = .persisted) {
        persistentContainer = NSPersistentCloudKitContainer(name: "GymTrackr")
        if storeType == .inMemory {
            persistentContainer.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        persistentContainer.loadPersistentStores(completionHandler: { _, error in
            if let error {
                fatalError("Core Data store failed to load with error: \(error)")
            }
        })
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }
}

// MARK: - API
extension PersistenceManager {

    func newBackgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        context.automaticallyMergesChangesFromParent = true
        return context
    }

    func deleteObjectWithId(_ id: NSManagedObjectID) async throws {
        try await withCheckedThrowingContinuation { [unowned self] (continuation: CheckedContinuation<Void, Error>) in
            let context = newBackgroundContext()
            context.perform {
                do {
                    let object = try context.existingObject(with: id)
                    context.delete(object)
                    try context.save()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

// MARK: - PersistenceManager.StoreType
extension PersistenceManager {

    enum StoreType {

        case inMemory
        case persisted
    }
}
