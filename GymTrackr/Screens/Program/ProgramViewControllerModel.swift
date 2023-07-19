//
//  ProgramViewControllerModel.swift
//  GymTrackr
//
//  Created by Sadık Kemal Sarı on 19.07.2023.
//

import Combine
import Foundation

// MARK: - ProgramViewControllerModel
final class ProgramViewControllerModel {

    // MARK: Types
    typealias Coordinator = ProgramCoordinator

    // MARK: Internal
    @Published private(set) var customViewModel: ProgramCustomViewModel
    @Published private(set) var taskState: TaskState<Error>?

    // MARK: Private
    private var cancellables: Set<AnyCancellable> = Set()
    private var coordinator: Coordinator
    private var persistenceManager: PersistenceManager
    private var programsProvider: ProgramProvider

    // MARK: Lifecycle
    init(coordinator: Coordinator, persistenceManager: PersistenceManager) {
        self.coordinator = coordinator
        self.persistenceManager = persistenceManager
        programsProvider = ProgramProvider(persistenceManager: persistenceManager)
        customViewModel = ProgramCustomViewModel(program: nil)
        loadBindings()
    }
}

// MARK: - Bindings
private extension ProgramViewControllerModel {

    func loadBindings() {
        programsProvider.contentDidChangePublisher
            .map { updatedProgram in
                ProgramCustomViewModel(program: updatedProgram.first)
            }
            .sink { [weak self] updatedCustomViewModel in
                guard let self else { return }
                customViewModel = updatedCustomViewModel
            }
            .store(in: &cancellables)
    }
}

// MARK: - Life Cycle API
extension ProgramViewControllerModel {

    func viewDidLoad() {
        taskState = .loading
        do {
            try programsProvider.fetch()
            taskState = .success
        } catch {
            taskState = .failure(error: error)
        }
    }
}

// MARK: - Actions API
extension ProgramViewControllerModel {

    func didTapAddProgram() {
        coordinator.routeToNewProgramScreen()
    }
}
