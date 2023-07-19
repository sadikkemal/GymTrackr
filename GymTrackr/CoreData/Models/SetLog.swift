//
//  SetLog.swift
//  GymTrackr
//
//  Created by Sadık Kemal Sarı on 19.07.2023.
//

import CoreData
import Foundation

// MARK: - SetLog
final class SetLog: NSManagedObject, Identifiable {

    @NSManaged var order: Int
    @NSManaged var reps: Int
    @NSManaged var weight: Int
    @NSManaged var exerciseLog: ExerciseLog
}

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
