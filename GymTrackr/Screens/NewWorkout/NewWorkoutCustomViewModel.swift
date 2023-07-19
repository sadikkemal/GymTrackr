//
//  NewWorkoutCustomViewModel.swift
//  GymTrackr
//
//  Created by Sadık Kemal Sarı on 19.07.2023.
//

import Combine
import UIKit

// MARK: - NewWorkoutCustomViewModel
struct NewWorkoutCustomViewModel: Hashable {

    // MARK: Types
    typealias Snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>
    typealias SectionIdentifier = Int

    // MARK: Internal
    let collectionViewPairs: [Pair]

    // MARK: Lifecycle
    init(workoutDraft: Workout.Draft) {
        var collectionViewPairs = [Pair]()

        // title
        let workoutNameInputItem = ItemIdentifier.generateForWorkoutNameInput(workoutDraft: workoutDraft)
        let workoutNamePair = Pair(
            section: workoutDraft.hashValue,
            items: [workoutNameInputItem])
        collectionViewPairs.append(workoutNamePair)

        // exercises
        for exerciseDraft in workoutDraft.exerciseDrafts {
            let exerciseDraftInputItem = ItemIdentifier.generateForExerciseDraftInput(exerciseDraft: exerciseDraft)
            let exerciseDraftPair = Pair(
                section: exerciseDraft.hashValue,
                items: [exerciseDraftInputItem])
            collectionViewPairs.append(exerciseDraftPair)
        }

        // addExercise
        let workoutAddExerciseInputItem = ItemIdentifier.generateForButton(text: workoutDraft.name)
        let workoutAddExercisePair = Pair(
            section: workoutDraft.hashValue + 1,
            items: [workoutAddExerciseInputItem])
        collectionViewPairs.append(workoutAddExercisePair)

        self.collectionViewPairs = collectionViewPairs
    }
}

// MARK: - API
extension NewWorkoutCustomViewModel {

    func snapshot() -> Snapshot {
        var snapshot = Snapshot()
        let sections = collectionViewPairs.map { pair in pair.section }
        snapshot.appendSections(sections)
        for collectionViewPair in collectionViewPairs {
            snapshot.appendItems(collectionViewPair.items, toSection: collectionViewPair.section)
        }
        return snapshot
    }
}

// MARK: - NewWorkoutCustomViewModel.Pair
extension NewWorkoutCustomViewModel {

    struct Pair: Hashable {

        let section: SectionIdentifier
        let items: [ItemIdentifier]
    }
}

// MARK: - NewWorkoutCustomViewModel.ItemIdentifier
extension NewWorkoutCustomViewModel {

    enum ItemIdentifier: Hashable {

        case textField(TextFieldCellContentConfiguration)
        case exercise(ExerciseInputCellContentConfiguration)
        case button(UIListContentConfiguration)

        var configuration: UIContentConfiguration {
            switch self {
            case .textField(let configuration): return configuration
            case .exercise(let configuration): return configuration
            case .button(let configuration): return configuration
            }
        }

        static func generateForWorkoutNameInput(workoutDraft: Workout.Draft) -> Self {
            let configuration = TextFieldCellContentConfiguration(
                id: workoutDraft.hashValue,
                placeholderText: "Workout Name",
                text: workoutDraft.name)
            return .textField(configuration)
        }

        static func generateForExerciseDraftInput(exerciseDraft: Exercise.Draft) -> Self {
            let configuration = ExerciseInputCellContentConfiguration(
                id: exerciseDraft.hashValue,
                text: exerciseDraft.name,
                selectedOption: exerciseDraft.setCount)
            return .exercise(configuration)
        }

        static func generateForButton(text _: String) -> Self {
            var configuration = UIListContentConfiguration.cell()
            configuration.text = "Add Exercise"
            configuration.textProperties.color = .tintColor
            return .button(configuration)
        }
    }
}
