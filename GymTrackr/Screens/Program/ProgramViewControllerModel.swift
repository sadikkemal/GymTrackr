//
//  ProgramViewControllerModel.swift
//  GymTrackr
//
//  Created by Sadık Kemal Sarı on 19.07.2023.
//

import Combine
import CoreData
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
    private var programProvider: ProgramProvider

    // MARK: Lifecycle
    init(coordinator: Coordinator, persistenceManager: PersistenceManager, programProvider: ProgramProvider) {
        self.coordinator = coordinator
        self.persistenceManager = persistenceManager
        self.programProvider = programProvider
        customViewModel = ProgramCustomViewModel(program: nil)
        loadBindings()
    }
}

// MARK: - Bindings
private extension ProgramViewControllerModel {

    func loadBindings() {
        programProvider.contentDidChangePublisher
            .map { updatedPrograms in
                ProgramCustomViewModel(program: updatedPrograms.first)
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
            try programProvider.fetch()
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
