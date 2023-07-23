//
//  WorkoutLog.swift
//  GymTrackr
//
//  Created by Sadık Kemal Sarı on 19.07.2023.
//

import CoreData
import Foundation

// MARK: - WorkoutLog
final class WorkoutLog: NSManagedObject, Identifiable, Codable {

    // MARK: Internal
    @NSManaged var creationDate: Date
    @NSManaged var workout: Workout
    @NSManaged var exerciseLogs: Set<Exercise>

    // MARK: Codable
    enum CodingKeys: CodingKey {
        case creationDate
        case exerciseLogs
    }

    convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.managedObjectContext] as? NSManagedObjectContext else {
            fatalError("Attempt to decode managed object with misconfigured decoder.")
        }

        self.init(context: context)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        creationDate = try container.decode(Date.self, forKey: .creationDate)
        exerciseLogs = try container.decode(Set<Exercise>.self, forKey: .exerciseLogs)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(creationDate, forKey: .creationDate)
        try container.encode(exerciseLogs, forKey: .exerciseLogs)
    }

    // MARK: - Lifecycle
    override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(Date(), forKey: #keyPath(WorkoutLog.creationDate))
    }
}

// MARK: - API
extension WorkoutLog {

    @nonobjc
    class func fetchRequest() -> NSFetchRequest<WorkoutLog> {
        NSFetchRequest<WorkoutLog>(entityName: "WorkoutLog")
    }
}
