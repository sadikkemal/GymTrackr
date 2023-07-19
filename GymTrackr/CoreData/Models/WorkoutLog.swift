//
//  WorkoutLog.swift
//  GymTrackr
//
//  Created by Sadık Kemal Sarı on 19.07.2023.
//

import CoreData
import Foundation

// MARK: - WorkoutLog
final class WorkoutLog: NSManagedObject, Identifiable {

    @NSManaged var creationDate: Date
    @NSManaged var workout: Workout
    @NSManaged var exerciseLogs: Set<Exercise>
}

extension WorkoutLog {

    @nonobjc
    class func fetchRequest() -> NSFetchRequest<WorkoutLog> {
        NSFetchRequest<WorkoutLog>(entityName: "WorkoutLog")
    }
}
