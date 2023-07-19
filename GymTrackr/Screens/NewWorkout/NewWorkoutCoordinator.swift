//
//  NewWorkoutCoordinator.swift
//  GymTrackr
//
//  Created by Sadık Kemal Sarı on 19.07.2023.
//

import UIKit

// MARK: - NewWorkoutCoordinator
final class NewWorkoutCoordinator {

    // MARK: Types
    typealias ViewController = NewWorkoutViewController

    // MARK: Internal
    weak var viewController: ViewController!
}

// MARK: - Lifecycle API
extension NewWorkoutCoordinator {

    func prepareScreen(workoutDraftIndex: Int?) -> ViewController {
        let persistenceManager = PersistenceManager.shared
        let userDefaultsManager = UserDefaultsManager.shared
        let viewModel = ViewController.ViewModel(
            coordinator: self,
            persistenceManager: persistenceManager,
            userDefaultsManager: userDefaultsManager,
            workoutDraftIndex: workoutDraftIndex)
        let viewController = ViewController(viewModel: viewModel)
        self.viewController = viewController
        return viewController
    }

    func dismiss() {
        viewController.dismiss(animated: true)
    }
}
