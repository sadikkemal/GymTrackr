//
//  ProgramCoordinator.swift
//  GymTrackr
//
//  Created by Sadık Kemal Sarı on 19.07.2023.
//

import UIKit

// MARK: - ProgramCoordinator
final class ProgramCoordinator {

    // MARK: Types
    typealias ViewController = ProgramViewController

    // MARK: Internal
    weak var viewController: ViewController!
}

// MARK: - Lifecycle API
extension ProgramCoordinator {

    func prepareScreen() -> ViewController {
        let persistenceManager = PersistenceManager.shared
        let programProvider = ProgramProvider(persistenceManager: persistenceManager)
        let viewModel = ViewController.ViewModel(
            coordinator: self,
            persistenceManager: persistenceManager,
            programProvider: programProvider)
        let viewController = ViewController(viewModel: viewModel)
        self.viewController = viewController
        return viewController
    }

    func dismiss() {
        viewController.dismiss(animated: true)
    }
}

// MARK: - Routing API
extension ProgramCoordinator {

    func routeToNewProgramScreen() {
        let coordinator = NewProgramCoordinator()
        let viewController = coordinator.prepareScreen()
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.isModalInPresentation = true
        self.viewController.present(navigationController, animated: true)
    }
}
