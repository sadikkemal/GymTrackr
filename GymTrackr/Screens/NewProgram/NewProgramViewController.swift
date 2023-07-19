//
//  NewProgramViewController.swift
//  GymTrackr
//
//  Created by Sadık Kemal Sarı on 19.07.2023.
//

import Combine
import UIKit

// MARK: - NewProgramViewController
final class NewProgramViewController: UIViewController {

    // MARK: Types
    typealias ViewModel = NewProgramViewControllerModel

    // MARK: Private
    private let viewModel: ViewModel
    private var cancellables: Set<AnyCancellable> = Set()
    private var shouldPresentOngoingProgramAlert = false
    private var shouldPresentDiscardProgramAlert = false

    private var customView: NewProgramCustomView {
        view as! NewProgramCustomView
    }

    // MARK: Lifecycle
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = NewProgramCustomView(viewModel: viewModel.customViewModel)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadNavigationItem()
        loadCustomViewBindings()
        loadViewModelBindings()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if shouldPresentOngoingProgramAlert {
            presentOngoingProgramAlert()
        }
    }
}

// MARK: - Views
private extension NewProgramViewController {

    func loadNavigationItem() {
        navigationItem.title = "New Program"

        let cancelAction = UIAction { [unowned self] _ in
            if shouldPresentDiscardProgramAlert {
                presentDiscardProgramAlert()
            } else {
                viewModel.didTapCancel()
            }
        }
        let cancelBarButtonItem = UIBarButtonItem(
            systemItem: .cancel,
            primaryAction: cancelAction)
        navigationItem.leftBarButtonItem = cancelBarButtonItem

        let saveAction = UIAction { [unowned self] _ in
            viewModel.didTapSave()
        }
        let saveBarButtonItem = UIBarButtonItem(
            systemItem: .save,
            primaryAction: saveAction)
        navigationItem.rightBarButtonItem = saveBarButtonItem
    }
}

// MARK: - Bindings
private extension NewProgramViewController {

    func loadCustomViewBindings() {
        customView.didTapCellPublisher
            .sink { [unowned self] indexPath in
                viewModel.didTapCell(at: indexPath)
            }
            .store(in: &cancellables)

        customView.didChangeTextPublisher
            .sink { [unowned self] indexPath, text in
                viewModel.didChangeText(at: indexPath, with: text)
            }
            .store(in: &cancellables)

        customView.didChangeTextPublisher
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [unowned self] indexPath, text in
                viewModel.didStopChangingText(at: indexPath, with: text)
            }
            .store(in: &cancellables)
    }

    func loadViewModelBindings() {
        viewModel.$customViewModel
            .sink { [unowned self] updatedCustomViewModel in
                customView.viewModel = updatedCustomViewModel
            }
            .store(in: &cancellables)

        viewModel.$taskState
            .receive(on: RunLoop.main)
            .sink { [weak self] taskState in
                guard let self else { return }
                if case .failure(let error) = taskState {
                    presentAlertController(for: error)
                }
            }
            .store(in: &cancellables)

        viewModel.$shouldPresentOngoingProgramAlert
            .receive(on: RunLoop.main)
            .assign(to: \.shouldPresentOngoingProgramAlert, on: self)
            .store(in: &cancellables)

        viewModel.$shouldPresentDiscardProgramAlert
            .receive(on: RunLoop.main)
            .assign(to: \.shouldPresentDiscardProgramAlert, on: self)
            .store(in: &cancellables)
    }
}

// MARK: - Dialogs
private extension NewProgramViewController {

    func presentOngoingProgramAlert() {
        let alertController = UIAlertController(
            title: "Ongoing Program",
            message: "Do you want to continue?",
            preferredStyle: .alert)

        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel)
        { [unowned self] _ in
            viewModel.didTapCancelOngoingProgram()
        }
        alertController.addAction(cancelAction)

        let continueAction = UIAlertAction(
            title: "Continue",
            style: .default)
        { [unowned self] _ in
            viewModel.didTapContinueOngoingProgram()
        }
        alertController.addAction(continueAction)

        present(alertController, animated: true)
    }

    func presentDiscardProgramAlert() {
        let alertController = UIAlertController(
            title: "Discard Program",
            message: "Do you want to continue?",
            preferredStyle: .alert)

        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel)
        alertController.addAction(cancelAction)

        let continueAction = UIAlertAction(
            title: "Discard",
            style: .destructive)
        { [unowned self] _ in
            viewModel.didTapCancel()
        }
        alertController.addAction(continueAction)

        present(alertController, animated: true)
    }
}
