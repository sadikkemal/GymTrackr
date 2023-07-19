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
final class Workout: NSManagedObject, Identifiable {

    @NSManaged var name: String
    @NSManaged var order: Int
    @NSManaged var exercises: Set<Exercise>
    @NSManaged var workoutLogs: Set<WorkoutLog>
    @NSManaged var program: Program?

    var sortedExercises: [Exercise] {
        exercises.sorted { $0.order < $1.order }
    }
}

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
