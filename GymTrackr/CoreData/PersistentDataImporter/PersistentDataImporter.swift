//
//  PersistentDataImporter.swift
//  GymTrackr
//
//  Created by Sadık Kemal Sarı on 21.07.2023.
//

import CoreData
import Foundation

// MARK: - PersistentDataImporter
final class PersistentDataImporter {

    // MARK: Private
    private let context: NSManagedObjectContext

    // MARK: Lifecycle
    init(context: NSManagedObjectContext) {
        self.context = context
    }
}

// MARK: - Helpers
private extension PersistentDataImporter {

    func importData<T: Decodable>(_ data: Data, as model: T.Type) async throws -> T {
        try await withCheckedThrowingContinuation { [unowned self] (continuation: CheckedContinuation<T, Error>) in
            context.perform { [unowned self] in
                do {
                    let decoder = JSONDecoder()
                    decoder.userInfo[.managedObjectContext] = context
                    let object = try decoder.decode(model, from: data)
                    try context.save()
                    continuation.resume(returning: object)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

// MARK: - API
extension PersistentDataImporter {

    func importObjectData<T: NSManagedObject & Decodable>(_ data: Data, as model: T.Type) async throws -> T {
        try await importData(data, as: model)
    }

    func importObjectCollectionData<T: Collection & Decodable>(_ data: Data, as model: T.Type) async throws -> T
        where T.Element: NSManagedObject
    {
        try await importData(data, as: model)
    }
}

// MARK: - CodingUserInfoKey
extension CodingUserInfoKey {

    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")!
}
