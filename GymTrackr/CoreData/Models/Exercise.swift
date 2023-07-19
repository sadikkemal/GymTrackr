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
final class Exercise: NSManagedObject, Identifiable {

    @NSManaged var name: String
    @NSManaged var order: Int
    @NSManaged var setCount: Int
    @NSManaged var exerciseLogs: Set<ExerciseLog>
    @NSManaged var workout: Workout?
}

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
