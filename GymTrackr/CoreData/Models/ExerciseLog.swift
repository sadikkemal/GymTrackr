//
//  ExerciseLog.swift
//  GymTrackr
//
//  Created by Sadık Kemal Sarı on 19.07.2023.
//

import CoreData
import Foundation

// MARK: - ExerciseLog
final class ExerciseLog: NSManagedObject, Identifiable, Codable {

    // MARK: Internal
    @NSManaged var exercise: Exercise
    @NSManaged var setLogs: Set<SetLog>

    // MARK: Codable
    enum CodingKeys: CodingKey {
        case setLogs
    }

    convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.managedObjectContext] as? NSManagedObjectContext else {
            fatalError("Attempt to decode managed object with misconfigured decoder.")
        }

        self.init(context: context)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        setLogs = try container.decode(Set<SetLog>.self, forKey: .setLogs)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(setLogs, forKey: .setLogs)
    }
}

// MARK: - API
extension ExerciseLog {

    @nonobjc
    class func fetchRequest() -> NSFetchRequest<ExerciseLog> {
        NSFetchRequest<ExerciseLog>(entityName: "ExerciseLog")
    }
}

// MARK: - ExerciseLog.Draft
extension ExerciseLog {

    struct Draft: Hashable, Codable {
        var id: String = UUID().uuidString
        var setLogDrafts: [SetLog.Draft]

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
}
