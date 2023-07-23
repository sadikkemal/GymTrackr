//
//  Workout+CoreDataClass.swift
//  GymTrackr
//
//  Created by Sadık Kemal Sarı on 19.07.2023.
//
//

import CoreData
import Foundation

// MARK: - Workout
final class Workout: NSManagedObject, Identifiable, Codable {

    // MARK: Internal
    @NSManaged var name: String
    @NSManaged var order: Int
    @NSManaged var exercises: Set<Exercise>
    @NSManaged var workoutLogs: Set<WorkoutLog>
    @NSManaged var program: Program?

    var sortedExercises: [Exercise] {
        exercises.sorted { $0.order < $1.order }
    }

    // MARK: Codable
    enum CodingKeys: CodingKey {
        case name
        case order
        case exercises
        case workoutLogs
    }

    convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.managedObjectContext] as? NSManagedObjectContext else {
            fatalError("Attempt to decode managed object with misconfigured decoder.")
        }

        self.init(context: context)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        order = try container.decode(Int.self, forKey: .order)
        exercises = try container.decode(Set<Exercise>.self, forKey: .exercises)
        workoutLogs = try container.decodeIfPresent(Set<WorkoutLog>.self, forKey: .workoutLogs) ?? Set()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(order, forKey: .order)
        try container.encode(exercises, forKey: .exercises)
        try container.encode(workoutLogs, forKey: .workoutLogs)
    }
}

// MARK: - API
extension Workout {

    @nonobjc
    class func fetchRequest() -> NSFetchRequest<Workout> {
        NSFetchRequest<Workout>(entityName: "Workout")
    }
}

// MARK: - Workout.Draft
extension Workout {

    struct Draft: Hashable, Codable {
        var id: String = UUID().uuidString
        var name: String
        var exerciseDrafts: [Exercise.Draft]

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
}
