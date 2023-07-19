//
//  ProgramProvider.swift
//  GymTrackr
//
//  Created by Sadık Kemal Sarı on 19.07.2023.
//

import Combine
import CoreData
import UIKit

// MARK: - ProgramProvider
final class ProgramProvider: NSObject {

    // MARK: Internal
    private(set) var contentDidChangePublisher: PassthroughSubject<[Program], Never> = PassthroughSubject()

    // MARK: Private
    private let fetchedResultsController: NSFetchedResultsController<Program>

    // MARK: Lifecycle
    init(persistenceManager: PersistenceManager) {
        let request: NSFetchRequest<Program> = Program.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Program.updateDate, ascending: false)]
        request.fetchBatchSize = 1

        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: persistenceManager.mainContext,
            sectionNameKeyPath: nil,
            cacheName: nil)

        super.init()

        fetchedResultsController.delegate = self
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension ProgramProvider: NSFetchedResultsControllerDelegate {

    func controller(
        _: NSFetchedResultsController<NSFetchRequestResult>,
        didChangeContentWith _: NSDiffableDataSourceSnapshotReference)
    {
        contentDidChangePublisher.send(fetchedResultsController.fetchedObjects ?? Array()) // Missing error management
    }
}

// MARK: - API
extension ProgramProvider {

    func fetch() throws {
        try fetchedResultsController.performFetch()
    }

    func object(at indexPath: IndexPath) -> Program {
        fetchedResultsController.object(at: indexPath)
    }
}
