//
//  Exercise+CoreDataClass.swift
//  GymTrackr
//
//  Created by Sadık Kemal Sarı on 19.07.2023.
//
//

import CoreData
import Foundation

// MARK: - Exercise
final class Exercise: NSManagedObject, Identifiable, Codable {

    // MARK: Internal
    @NSManaged var name: String
    @NSManaged var order: Int
    @NSManaged var setCount: Int
    @NSManaged var exerciseLogs: Set<ExerciseLog>
    @NSManaged var workout: Workout?

    // MARK: Codable
    enum CodingKeys: CodingKey {
        case name
        case order
        case setCount
        case exerciseLogs
    }

    convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.managedObjectContext] as? NSManagedObjectContext else {
            fatalError("Attempt to decode managed object with misconfigured decoder.")
        }

        self.init(context: context)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        order = try container.decode(Int.self, forKey: .order)
        setCount = try container.decode(Int.self, forKey: .setCount)
        exerciseLogs = try container.decodeIfPresent(Set<ExerciseLog>.self, forKey: .exerciseLogs) ?? Set()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(order, forKey: .order)
        try container.encode(setCount, forKey: .setCount)
        try container.encode(exerciseLogs, forKey: .exerciseLogs)
    }
}

// MARK: - API
extension Exercise {

    @nonobjc
    class func fetchRequest() -> NSFetchRequest<Exercise> {
        NSFetchRequest<Exercise>(entityName: "Exercise")
    }
}

// MARK: - Exercise.Draft
extension Exercise {

    struct Draft: Hashable, Codable {
        var id: String = UUID().uuidString
        var name: String
        var setCount: Int

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
}
