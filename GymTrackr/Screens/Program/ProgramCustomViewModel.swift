//
//  ProgramCustomViewModel.swift
//  GymTrackr
//
//  Created by Sadık Kemal Sarı on 19.07.2023.
//

import UIKit

// MARK: - ProgramCustomViewModel
struct ProgramCustomViewModel: Hashable {

    // MARK: Types
    typealias SectionIdentifier = Int
    typealias Snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>
    typealias SectionSnapshot = NSDiffableDataSourceSectionSnapshot<ItemIdentifier>

    // MARK: Internal
    let collectionViewPairs: [Pair]

    // MARK: Lifecycle
    init(program: Program?) {
        var collectionViewPairs = [Pair]()

        if let program {
            for workout in program.sortedWorkouts {
                // title
                let workoutItem = ItemIdentifier.generateForWorkout(workout: workout)

                // exercises
                let exerciseItems = workout.sortedExercises.map { exercise in
                    ItemIdentifier.generateForExercise(exercise: exercise)
                }

                // pair
                let workoutPair = Pair(
                    section: workout.objectID.hashValue,
                    items: [workoutItem] + exerciseItems)

                collectionViewPairs.append(workoutPair)
            }
        }

        self.collectionViewPairs = collectionViewPairs
    }
}

// MARK: - API
extension ProgramCustomViewModel {

    func snapshot() -> Snapshot {
        var snapshot = Snapshot()
        let sections = collectionViewPairs.map { pair in pair.section }
        snapshot.appendSections(sections)
        return snapshot
    }

    func sectionSnapshots() -> [(SectionIdentifier, SectionSnapshot)] {
        var sectionSnapshots = [(SectionIdentifier, SectionSnapshot)]()
        for collectionViewPair in collectionViewPairs {
            var sectionSnapshot = SectionSnapshot()
            let headerItem = collectionViewPair.items.first!
            let cellItems = Array(collectionViewPair.items.dropFirst())
            sectionSnapshot.append([headerItem])
            sectionSnapshot.append(cellItems, to: headerItem)
            sectionSnapshot.expand([headerItem])
            sectionSnapshots.append((collectionViewPair.section, sectionSnapshot))
        }
        return sectionSnapshots
    }
}

// MARK: - ProgramCustomViewModel.Pair
extension ProgramCustomViewModel {

    struct Pair: Hashable {

        let section: SectionIdentifier
        let items: [ItemIdentifier]
    }
}

// MARK: - ProgramCustomViewModel.ItemIdentifier
extension ProgramCustomViewModel {

    enum ItemIdentifier: Hashable {

        case text(Int, UIListContentConfiguration)

        // MARK: Internal
        var configuration: UIContentConfiguration {
            switch self {
            case .text(_, let configuration): return configuration
            }
        }

        static func generateForWorkout(workout: Workout) -> Self {
            var configuration = UIListContentConfiguration.plainHeader()
            configuration.text = workout.name
            return .text(workout.objectID.hashValue, configuration)
        }

        static func generateForExercise(exercise: Exercise) -> Self {
            var configuration = UIListContentConfiguration.valueCell()
            configuration.text = exercise.name
            configuration.prefersSideBySideTextAndSecondaryText = true
            configuration.secondaryText = String(exercise.setCount)
            return .text(exercise.objectID.hashValue, configuration)
        }
    }
}
