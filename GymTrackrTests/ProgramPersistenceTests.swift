//
//  ProgramPersistenceTests.swift
//  GymTrackrTests
//
//  Created by Sadık Kemal Sarı on 19.07.2023.
//

import CoreData
import XCTest
@testable import GymTrackr

// MARK: - ProgramPersistenceTests
final class ProgramPersistenceTests: XCTestCase {

    var persistenceManager: PersistenceManager!

    override func setUpWithError() throws {
        try super.setUpWithError()
        persistenceManager = .newInMemory
    }

    override func tearDownWithError() throws {
        persistenceManager = nil
        try super.tearDownWithError()
    }

    func testSaveProgram() async throws {
        let programDraft = Self.generateProgramDraft()
        try await persistenceManager.saveProgram(programDraft: programDraft)

        let request: NSFetchRequest<Program> = Program.fetchRequest()
        let programs = try persistenceManager.mainContext.fetch(request)

        XCTAssertEqual(programs.count, 1)

        let program = try XCTUnwrap(programs.first)
        XCTAssertEqual(program.name, programDraft.name)
        XCTAssertEqual(program.workouts.count, programDraft.workoutDrafts.count)

        for workoutDraftIndex in 0..<programDraft.workoutDrafts.count {
            let workoutDraft = programDraft.workoutDrafts[workoutDraftIndex]
            let workout = program.sortedWorkouts[workoutDraftIndex]
            XCTAssertEqual(workout.name, workoutDraft.name)
            XCTAssertEqual(workout.order, workoutDraftIndex)
            XCTAssertTrue(workout.workoutLogs.isEmpty)

            for exerciseDraftIndex in 0 ..< workoutDraft.exerciseDrafts.count {
                let exerciseDraft = workoutDraft.exerciseDrafts[exerciseDraftIndex]
                let exercise = workout.sortedExercises[exerciseDraftIndex]
                XCTAssertEqual(exercise.name, exerciseDraft.name)
                XCTAssertEqual(exercise.order, exerciseDraftIndex)
                XCTAssertEqual(exercise.setCount, exerciseDraft.setCount)
                XCTAssertTrue(exercise.exerciseLogs.isEmpty)
            }
        }
    }
}

// MARK: - Helpers
private extension ProgramPersistenceTests {

    static func generateProgramDraft() -> Program.Draft {
        let programDraft = Program.Draft(
            name: "4-Day Program",
            workoutDrafts: [
                Workout.Draft(
                    name: "Day 1 - Chest & Abs",
                    exerciseDrafts: [
                        Exercise.Draft(name: "Bench Press", setCount: 4),
                        Exercise.Draft(name: "Incline Dumbbell Press", setCount: 4),
                        Exercise.Draft(name: "Cable Crossover", setCount: 4),
                        Exercise.Draft(name: "Dumbbell Pullovers", setCount: 4),
                        Exercise.Draft(name: "Hanging Leg Raises", setCount: 4),
                        Exercise.Draft(name: "Plank", setCount: 3),
                    ]),
                Workout.Draft(
                    name: "Day 2 - Legs & Triceps",
                    exerciseDrafts: [
                        Exercise.Draft(name: "Squats", setCount: 4),
                        Exercise.Draft(name: "Lunges", setCount: 4),
                        Exercise.Draft(name: "Leg Press", setCount: 4),
                        Exercise.Draft(name: "Calf Raises", setCount: 4),
                        Exercise.Draft(name: "Skull Crushers", setCount: 4),
                        Exercise.Draft(name: "Tricep Dips", setCount: 4),
                    ]),
                Workout.Draft(
                    name: "Day 3 - Back & Biceps",
                    exerciseDrafts: [
                        Exercise.Draft(name: "Deadlift", setCount: 4),
                        Exercise.Draft(name: "Bent Over Row", setCount: 4),
                        Exercise.Draft(name: "Lat Pulldown", setCount: 4),
                        Exercise.Draft(name: "Seated Cable Row", setCount: 4),
                        Exercise.Draft(name: "Barbell Curls", setCount: 4),
                        Exercise.Draft(name: "Hammer Curls", setCount: 3),
                    ]),
                Workout.Draft(
                    name: "Day 4 - Shoulders & Abs",
                    exerciseDrafts: [
                        Exercise.Draft(name: "Military Press", setCount: 4),
                        Exercise.Draft(name: "Lateral Raises", setCount: 4),
                        Exercise.Draft(name: "Rear Delt Flyes", setCount: 4),
                        Exercise.Draft(name: "Upright Rows", setCount: 4),
                        Exercise.Draft(name: "Reverse Crunches", setCount: 4),
                        Exercise.Draft(name: "Russian Twists", setCount: 3),
                    ]),
            ])
        return programDraft
    }
}
