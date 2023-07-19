//
//  NewProgramViewControllerModel.swift
//  GymTrackr
//
//  Created by Sadık Kemal Sarı on 19.07.2023.
//

import Combine
import Foundation
import UIKit

// MARK: - NewProgramViewControllerModel
final class NewProgramViewControllerModel {

    // MARK: Types
    typealias Coordinator = NewProgramCoordinator

    // MARK: Internal
    @Published private(set) var customViewModel: NewProgramCustomViewModel
    @Published private(set) var taskState: TaskState<Error>?
    @Published private(set) var shouldPresentOngoingProgramAlert: Bool
    @Published private(set) var shouldPresentDiscardProgramAlert = false

    // MARK: Private
    private var cancellables: Set<AnyCancellable> = Set()
    private let coordinator: Coordinator
    private let persistenceManager: PersistenceManager
    private let userDefaultsManager: UserDefaultsManager
    private var programDraft: Program.Draft {
        didSet { shouldPresentDiscardProgramAlert = !isProgramDraftEmpty() }
    }

    // MARK: Lifecycle
    init(coordinator: Coordinator, persistenceManager: PersistenceManager, userDefaultsManager: UserDefaultsManager) {
        self.coordinator = coordinator
        self.persistenceManager = persistenceManager
        self.userDefaultsManager = userDefaultsManager
        programDraft = Self.generateProgramDraft()
        shouldPresentOngoingProgramAlert = userDefaultsManager.ongoingProgramDraft != nil
        customViewModel = NewProgramCustomViewModel(programDraft: programDraft)
        loadBindings()
    }
}

// MARK: - Bindings
private extension NewProgramViewControllerModel {

    func loadBindings() {
        userDefaultsManager.$ongoingProgramDraft
            .sink { [weak self] ongoingProgramDraft in
                guard let self else { return }
                guard let ongoingProgramDraft else { return }
                guard coordinator.hasPresentedViewController else { return }
                programDraft = ongoingProgramDraft
                customViewModel = NewProgramCustomViewModel(programDraft: programDraft)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Helpers
private extension NewProgramViewControllerModel {

    static func generateProgramDraft() -> Program.Draft {
        let programDraft = Program.Draft(
            name: String(),
            workoutDrafts: Array())
        return programDraft
    }

    func updateText(at _: IndexPath, with text: String) {
        programDraft.name = text
        customViewModel = NewProgramCustomViewModel(programDraft: programDraft)
    }

    func validateProgramDraft() throws {
        guard !programDraft.name.isEmpty else { throw InternalError.missingProgramName }
        guard !programDraft.workoutDrafts.isEmpty else { throw InternalError.missingWorkout }
    }

    func isProgramDraftEmpty() -> Bool {
        guard programDraft.name.isEmpty else { return false }
        guard programDraft.workoutDrafts.isEmpty else { return false }
        return true
    }
}

// MARK: - Actions API
extension NewProgramViewControllerModel {

    func didTapCancel() {
        userDefaultsManager.ongoingProgramDraft = nil
        coordinator.dismiss()
    }

    func didTapSave() {
        taskState = .loading
        Task {
            do {
                try validateProgramDraft()
                try await persistenceManager.saveProgram(programDraft: programDraft)
                userDefaultsManager.ongoingProgramDraft = nil
                taskState = .success
                await MainActor.run {
                    coordinator.dismiss()
                }
            } catch {
                taskState = .failure(error: error)
            }
        }
    }

    func didTapCell(at indexPath: IndexPath) {
        let item = customViewModel.collectionViewPairs[indexPath.section].items[indexPath.item]
        if case .button = item {
            if !isProgramDraftEmpty() {
                userDefaultsManager.ongoingProgramDraft = programDraft
            }
            coordinator.routeToNewWorkoutScreen()
        }
    }

    func didChangeText(at indexPath: IndexPath, with text: String) {
        updateText(at: indexPath, with: text)
    }

    func didStopChangingText(at _: IndexPath, with _: String) {
        userDefaultsManager.ongoingProgramDraft = programDraft
    }

    func didTapCancelOngoingProgram() {
        userDefaultsManager.ongoingProgramDraft = nil
    }

    func didTapContinueOngoingProgram() {
        programDraft = userDefaultsManager.ongoingProgramDraft!
        customViewModel = NewProgramCustomViewModel(programDraft: programDraft)
    }
}

// MARK: - NewProgramViewControllerModel.InternalError
extension NewProgramViewControllerModel {

    enum InternalError: LocalizedError {

        case missingProgramName
        case missingWorkout

        var errorDescription: String? {
            switch self {
            case .missingProgramName: return "Please enter a program name."
            case .missingWorkout: return "Please add a workout."
            }
        }
    }
}
