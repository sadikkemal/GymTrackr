//
//  PersistenceManager+Program.swift
//  GymTrackr
//
//  Created by Sadık Kemal Sarı on 19.07.2023.
//

import CoreData
import Foundation

extension PersistenceManager {

    func saveProgram(programDraft: Program.Draft) async throws {
        try await withCheckedThrowingContinuation { [unowned self] (continuation: CheckedContinuation<Void, Error>) in
            let context = newBackgroundContext()
            context.perform {
                do {
                    let program = Program(context: context)
                    program.name = programDraft.name

                    var workouts = Set<Workout>()
                    for workoutDraftIndex in 0 ..< programDraft.workoutDrafts.count {
                        let workoutDraft = programDraft.workoutDrafts[workoutDraftIndex]
                        let workout = Workout(context: context)
                        workout.name = workoutDraft.name
                        workout.order = workoutDraftIndex

                        var exercises = Set<Exercise>()
                        for exerciseDraftIndex in 0 ..< workoutDraft.exerciseDrafts.count {
                            let exerciseDraft = workoutDraft.exerciseDrafts[exerciseDraftIndex]
                            let exercise = Exercise(context: context)
                            exercise.name = exerciseDraft.name
                            exercise.order = exerciseDraftIndex
                            exercise.setCount = exerciseDraft.setCount
                            exercise.exerciseLogs = Set()
                            exercises.insert(exercise)
                        }
                        workout.exercises = exercises

                        workout.workoutLogs = Set()
                        workouts.insert(workout)
                    }
                    program.workouts = workouts

                    try context.save()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
