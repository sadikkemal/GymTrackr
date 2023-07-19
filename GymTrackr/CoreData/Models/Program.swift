//
//  Program+CoreDataClass.swift
//  GymTrackr
//
//  Created by Sadık Kemal Sarı on 19.07.2023.
//
//

import CoreData
import Foundation

// MARK: - Program
final class Program: NSManagedObject, Identifiable {

    @NSManaged var creationDate: Date
    @NSManaged var updateDate: Date
    @NSManaged var name: String
    @NSManaged var workouts: Set<Workout>

    var sortedWorkouts: [Workout] {
        workouts.sorted { $0.order < $1.order }
    }
}

extension Program {

    @nonobjc
    class func fetchRequest() -> NSFetchRequest<Program> {
        NSFetchRequest<Program>(entityName: "Program")
    }
}

extension Program {

    override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(Date(), forKey: #keyPath(Program.creationDate))
        setPrimitiveValue(Date(), forKey: #keyPath(Program.updateDate))
    }

    override func willSave() {
        super.willSave()
        setPrimitiveValue(Date(), forKey: #keyPath(Program.updateDate))
    }
}

// MARK: - Program.Draft
extension Program {

    struct Draft: Hashable, Codable {
        var id: String = UUID().uuidString
        var name: String
        var workoutDrafts: [Workout.Draft]

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
}
