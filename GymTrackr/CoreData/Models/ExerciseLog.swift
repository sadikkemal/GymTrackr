//
//  ExerciseLog.swift
//  GymTrackr
//
//  Created by Sadık Kemal Sarı on 19.07.2023.
//

import CoreData
import Foundation

// MARK: - ExerciseLog
final class ExerciseLog: NSManagedObject, Identifiable {

    @NSManaged var exercise: Exercise
    @NSManaged var setLogs: Set<SetLog>
}

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
