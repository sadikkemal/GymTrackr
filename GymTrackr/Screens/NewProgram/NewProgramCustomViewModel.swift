//
//  NewProgramCustomViewModel.swift
//  GymTrackr
//
//  Created by Sadık Kemal Sarı on 19.07.2023.
//

import Combine
import UIKit

// MARK: - NewProgramCustomViewModel
struct NewProgramCustomViewModel: Hashable {

    // MARK: Types
    typealias Snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>
    typealias SectionIdentifier = Int

    // MARK: Internal
    let collectionViewPairs: [Pair]

    // MARK: Lifecycle
    init(programDraft: Program.Draft) {
        var collectionViewPairs = [Pair]()

        // title
        let programNameHeaderItem = ItemIdentifier.generateForHeader(text: "Program Name")
        let programNameInputItem = ItemIdentifier.generateForProgramNameInput(programDraft: programDraft)
        let programNamePair = Pair(
            section: programDraft.hashValue,
            items: [programNameHeaderItem, programNameInputItem])
        collectionViewPairs.append(programNamePair)

        // workout
        for workoutDraft in programDraft.workoutDrafts {
            var workoutItems = [ItemIdentifier]()

            let workoutHeaderItem = ItemIdentifier.generateForHeader(text: workoutDraft.name)
            workoutItems.append(workoutHeaderItem)

            for exerciseDraft in workoutDraft.exerciseDrafts {
                let exerciseItem = ItemIdentifier.generateForExercise(exerciseDraft: exerciseDraft)
                workoutItems.append(exerciseItem)
            }

            let workoutPair = Pair(
                section: workoutDraft.hashValue,
                items: workoutItems)
            collectionViewPairs.append(workoutPair)
        }

        // addWorkout
        let programAddWorkoutHeaderItem = ItemIdentifier.generateForHeader(text: "Add Workout")
        let programAddWorkoutInputItem = ItemIdentifier.generateForButton(text: programDraft.name)
        let programAddWorkoutPair = Pair(
            section: programDraft.hashValue + 1,
            items: [programAddWorkoutHeaderItem, programAddWorkoutInputItem])
        collectionViewPairs.append(programAddWorkoutPair)

        self.collectionViewPairs = collectionViewPairs
    }
}

// MARK: - API
extension NewProgramCustomViewModel {

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

// MARK: - NewProgramCustomViewModel.Pair
extension NewProgramCustomViewModel {

    struct Pair: Hashable {

        let section: SectionIdentifier
        let items: [ItemIdentifier]
    }
}

// MARK: - NewProgramCustomViewModel.ItemIdentifier
extension NewProgramCustomViewModel {

    enum ItemIdentifier: Hashable {

        case text(UIListContentConfiguration)
        case textField(TextFieldCellContentConfiguration)
        case button(UIListContentConfiguration)

        var configuration: UIContentConfiguration {
            switch self {
            case .text(let configuration): return configuration
            case .textField(let configuration): return configuration
            case .button(let configuration): return configuration
            }
        }

        static func generateForHeader(text: String) -> Self {
            var configuration = UIListContentConfiguration.plainHeader()
            configuration.text = text
            return .text(configuration)
        }

        static func generateForProgramNameInput(programDraft: Program.Draft) -> Self {
            let configuration = TextFieldCellContentConfiguration(
                id: programDraft.hashValue,
                placeholderText: "Program Name",
                text: programDraft.name)
            return .textField(configuration)
        }

        static func generateForExercise(exerciseDraft: Exercise.Draft) -> Self {
            var configuration = UIListContentConfiguration.cell()
            configuration.text = exerciseDraft.name
            return .text(configuration)
        }

        static func generateForButton(text _: String) -> Self {
            var configuration = UIListContentConfiguration.cell()
            configuration.text = "Add Workout"
            configuration.textProperties.color = .tintColor
            return .button(configuration)
        }
    }
}
