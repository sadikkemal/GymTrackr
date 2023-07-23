//
//  SetLog.swift
//  GymTrackr
//
//  Created by Sadık Kemal Sarı on 19.07.2023.
//

import CoreData
import Foundation

// MARK: - SetLog
final class SetLog: NSManagedObject, Identifiable, Codable {

    // MARK: Internal
    @NSManaged var order: Int
    @NSManaged var reps: Int
    @NSManaged var weight: Int
    @NSManaged var exerciseLog: ExerciseLog

    // MARK: Codable
    enum CodingKeys: CodingKey {
        case order
        case reps
        case weight
    }

    convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.managedObjectContext] as? NSManagedObjectContext else {
            fatalError("Attempt to decode managed object with misconfigured decoder.")
        }

        self.init(context: context)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        order = try container.decode(Int.self, forKey: .order)
        reps = try container.decode(Int.self, forKey: .reps)
        weight = try container.decode(Int.self, forKey: .weight)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(order, forKey: .order)
        try container.encode(reps, forKey: .reps)
        try container.encode(weight, forKey: .weight)
    }
}

// MARK: - API
extension SetLog {

    @nonobjc
    class func fetchRequest() -> NSFetchRequest<SetLog> {
        NSFetchRequest<SetLog>(entityName: "SetLog")
    }
}

// MARK: - SetLog.Draft
extension SetLog {

    struct Draft: Hashable, Codable {
        var id: String = UUID().uuidString
        var reps: Int
        var weight: Int

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
}
