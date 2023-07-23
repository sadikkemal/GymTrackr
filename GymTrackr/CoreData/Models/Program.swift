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
final class Program: NSManagedObject, Identifiable, Codable {

    // MARK: Internal
    @NSManaged var creationDate: Date
    @NSManaged var updateDate: Date
    @NSManaged var name: String
    @NSManaged var workouts: Set<Workout>

    var sortedWorkouts: [Workout] {
        workouts.sorted { $0.order < $1.order }
    }

    // MARK: Codable
    enum CodingKeys: CodingKey {
        case creationDate
        case updateDate
        case name
        case workouts
    }

    convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.managedObjectContext] as? NSManagedObjectContext else {
            fatalError("Attempt to decode managed object with misconfigured decoder.")
        }

        self.init(context: context)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        creationDate = try container.decode(Date.self, forKey: .creationDate)
        updateDate = try container.decode(Date.self, forKey: .updateDate)
        name = try container.decode(String.self, forKey: .name)
        workouts = try container.decode(Set<Workout>.self, forKey: .workouts)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(creationDate, forKey: .creationDate)
        try container.encode(updateDate, forKey: .updateDate)
        try container.encode(name, forKey: .name)
        try container.encode(workouts, forKey: .workouts)
    }

    // MARK: - Lifecycle
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

// MARK: - API
extension Program {

    @nonobjc
    class func fetchRequest() -> NSFetchRequest<Program> {
        NSFetchRequest<Program>(entityName: "Program")
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
