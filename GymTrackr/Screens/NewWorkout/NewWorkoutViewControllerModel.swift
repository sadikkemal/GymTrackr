//
//  NewWorkoutViewControllerModel.swift
//  GymTrackr
//
//  Created by Sadık Kemal Sarı on 19.07.2023.
//

import Combine
import Foundation
import UIKit

// MARK: - NewWorkoutViewControllerModel
final class NewWorkoutViewControllerModel {

    // MARK: Types
    typealias Coordinator = NewWorkoutCoordinator

    // MARK: Internal
    @Published private(set) var customViewModel: NewWorkoutCustomViewModel
    @Published private(set) var taskState: TaskState<Error>?

    // MARK: Private
    private var cancellables: Set<AnyCancellable> = Set()
    private let coordinator: Coordinator
    private let persistenceManager: PersistenceManager
    private let userDefaultsManager: UserDefaultsManager
    private let workoutDraftIndex: Int?
    private var workoutDraft: Workout.Draft

    // MARK: Lifecycle
    init(
        coordinator: Coordinator,
        persistenceManager: PersistenceManager,
        userDefaultsManager: UserDefaultsManager,
        workoutDraftIndex: Int?)
    {
        self.coordinator = coordinator
        self.persistenceManager = persistenceManager
        self.userDefaultsManager = userDefaultsManager
        self.workoutDraftIndex = workoutDraftIndex
        if let workoutDraftIndex, let ongoingProgramDraft = userDefaultsManager.ongoingProgramDraft {
            workoutDraft = ongoingProgramDraft.workoutDrafts[workoutDraftIndex]
        } else {
            workoutDraft = Self.generateWorkoutDraft()
        }
        customViewModel = NewWorkoutCustomViewModel(workoutDraft: workoutDraft)
    }
}

// MARK: - Helpers
private extension NewWorkoutViewControllerModel {

    static func generateProgramDraft() -> Program.Draft {
        let programDraft = Program.Draft(
            name: String(),
            workoutDrafts: Array())
        return programDraft
    }

    static func generateWorkoutDraft() -> Workout.Draft {
        let workoutDraft = Workout.Draft(
            name: String(),
            exerciseDrafts: [generateExerciseDraft(), generateExerciseDraft(), generateExerciseDraft()])
        return workoutDraft
    }

    static func generateExerciseDraft() -> Exercise.Draft {
        let exerciseDraft = Exercise.Draft(name: String(), setCount: 0)
        return exerciseDraft
    }

    func addExercise() {
        let exerciseDraft = Self.generateExerciseDraft()
        workoutDraft.exerciseDrafts.append(exerciseDraft)
        customViewModel = NewWorkoutCustomViewModel(workoutDraft: workoutDraft)
    }

    func updateText(at indexPath: IndexPath, with text: String) {
        if indexPath.section == 0 {
            workoutDraft.name = text
        } else {
            let exerciseDraftIndex = indexPath.section - 1
            workoutDraft.exerciseDrafts[exerciseDraftIndex].name = text
        }
        customViewModel = NewWorkoutCustomViewModel(workoutDraft: workoutDraft)
    }

    func updateOption(at indexPath: IndexPath, with option: Int) {
        let exerciseDraftIndex = indexPath.section - 1
        workoutDraft.exerciseDrafts[exerciseDraftIndex].setCount = option
        customViewModel = NewWorkoutCustomViewModel(workoutDraft: workoutDraft)
    }

    func validateWorkoutDraft() throws {
        guard !workoutDraft.name.isEmpty else { throw InternalError.missingWorkoutName }
        for exerciseDraft in workoutDraft.exerciseDrafts {
            guard !exerciseDraft.name.isEmpty else { throw InternalError.missingExerciseName }
            guard exerciseDraft.setCount > 0 else { throw InternalError.missingExerciseSetCount }
        }
    }
}

// MARK: - Actions API
extension NewWorkoutViewControllerModel {

    func didTapCancel() {
        coordinator.dismiss()
    }

    func didTapSave() {
        do {
            try validateWorkoutDraft()
            var ongoingProgramDraft = userDefaultsManager.ongoingProgramDraft ?? Self.generateProgramDraft()
            if let workoutDraftIndex {
                ongoingProgramDraft.workoutDrafts[workoutDraftIndex] = workoutDraft
            } else {
                ongoingProgramDraft.workoutDrafts.append(workoutDraft)
            }
            userDefaultsManager.ongoingProgramDraft = ongoingProgramDraft
            coordinator.dismiss()
        } catch {
            taskState = .failure(error: error)
        }
    }

    func didTapCell(at indexPath: IndexPath) {
        let item = customViewModel.collectionViewPairs[indexPath.section].items[indexPath.item]
        if case .button = item {
            addExercise()
        }
    }

    func didChangeText(at indexPath: IndexPath, with text: String) {
        updateText(at: indexPath, with: text)
    }

    func didSelectOption(at indexPath: IndexPath, with option: Int) {
        updateOption(at: indexPath, with: option)
    }
}

// MARK: - NewWorkoutViewControllerModel.InternalError
extension NewWorkoutViewControllerModel {

    enum InternalError: LocalizedError {

        case missingWorkoutName
        case missingExerciseName
        case missingExerciseSetCount

        var errorDescription: String? {
            switch self {
            case .missingWorkoutName: return "Please enter a workout name."
            case .missingExerciseName: return "Please enter an exercise name."
            case .missingExerciseSetCount: return "Please select the number of exercise sets."
            }
        }
    }
}
