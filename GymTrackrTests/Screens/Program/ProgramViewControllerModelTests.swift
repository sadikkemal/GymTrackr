//
//  ProgramViewControllerModelTests.swift
//  GymTrackrTests
//
//  Created by Sadık Kemal Sarı on 21.07.2023.
//

import Combine
import CoreData
import XCTest
@testable import GymTrackr

// MARK: - ProgramViewControllerModelTests
final class ProgramViewControllerModelTests: XCTestCase {

    // MARK: Private
    private var persistenceManager: PersistenceManager!
    private var programProvider: ProgramProvider!
    private var programViewControllerModel: ProgramViewControllerModel!
    private var persistentDataImporter: PersistentDataImporter!

    // MARK: Lifecycle
    override func setUpWithError() throws {
        try super.setUpWithError()
        let coordinator = ProgramCoordinator()
        persistenceManager = PersistenceManager.newInMemory
        programProvider = ProgramProvider(persistenceManager: persistenceManager)
        programViewControllerModel = ProgramViewControllerModel(
            coordinator: coordinator,
            persistenceManager: persistenceManager,
            programProvider: programProvider)
        persistentDataImporter = PersistentDataImporter(context: persistenceManager.newBackgroundContext())
    }

    override func tearDownWithError() throws {
        persistenceManager = nil
        programProvider = nil
        programViewControllerModel = nil
        persistentDataImporter = nil
        try super.tearDownWithError()
    }
}

// MARK: - Helpers
private extension ProgramViewControllerModelTests {

    func importProgramMock() async throws -> Program {
        let url = Bundle.main.url(forResource: "ProgramMock", withExtension: "json")!
        let data = try Data(contentsOf: url)
        let program = try await persistentDataImporter.importObjectData(data, as: Program.self)
        return program
    }
}

// MARK: - Tests
extension ProgramViewControllerModelTests {

    func testCustomViewModel() async throws {
        var optionalCustomViewModel: ProgramCustomViewModel? = nil
        let expectation = expectation(description: "ProgramCustomViewModel")

        let program = try await importProgramMock()
        try programProvider.fetch()

        let cancellable = programViewControllerModel.$customViewModel
            .sink { updatedCustomViewModel in
                optionalCustomViewModel = updatedCustomViewModel
                expectation.fulfill()
            }

        await fulfillment(of: [expectation])

        let customViewModel = try XCTUnwrap(optionalCustomViewModel)
        for workoutIndex in 0..<program.sortedWorkouts.count {
            let workout = program.sortedWorkouts[workoutIndex]
            let workoutPair = customViewModel.collectionViewPairs[workoutIndex]
            XCTAssertEqual(workout.objectID.hashValue, workoutPair.section)

            let workoutItem = try XCTUnwrap(workoutPair.items.first)
            guard case .text(_, let workoutItemConfiguration) = workoutItem else {
                XCTFail()
                return
            }
            XCTAssertEqual(workoutItemConfiguration.text, workout.name)

            for exerciseIndex in 0..<workout.sortedExercises.count {
                let exercise = workout.sortedExercises[exerciseIndex]

                let exerciseItem = workoutPair.items[exerciseIndex + 1]
                guard case .text(_, let exerciseItemConfiguration) = exerciseItem else {
                    XCTFail()
                    return
                }
                XCTAssertEqual(exerciseItemConfiguration.text, exercise.name)
            }
        }
    }
}
