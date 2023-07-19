//
//  NewProgramCoordinator.swift
//  GymTrackr
//
//  Created by Sadık Kemal Sarı on 19.07.2023.
//

import CoreData
import UIKit

// MARK: - NewProgramCoordinator
final class NewProgramCoordinator {

    // MARK: Types
    typealias ViewController = NewProgramViewController

    // MARK: Internal
    weak var viewController: ViewController!
    var hasPresentedViewController: Bool {
        viewController.presentedViewController != nil
    }
}

// MARK: - Lifecycle API
extension NewProgramCoordinator {

    func prepareScreen() -> ViewController {
        let persistenceManager = PersistenceManager.shared
        let userDefaultsManager = UserDefaultsManager.shared
        let viewModel = ViewController.ViewModel(
            coordinator: self,
            persistenceManager: persistenceManager,
            userDefaultsManager: userDefaultsManager)
        let viewController = ViewController(viewModel: viewModel)
        self.viewController = viewController
        return viewController
    }

    func dismiss() {
        viewController.dismiss(animated: true)
    }
}

// MARK: - Routing API
extension NewProgramCoordinator {

    func routeToNewWorkoutScreen() {
        let coordinator = NewWorkoutCoordinator()
        let viewController = coordinator.prepareScreen(workoutDraftIndex: nil)
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.isModalInPresentation = true
        self.viewController.present(navigationController, animated: true)
    }
}
