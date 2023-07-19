//
//  NewWorkoutViewController.swift
//  GymTrackr
//
//  Created by Sadık Kemal Sarı on 19.07.2023.
//

import Combine
import UIKit

// MARK: - NewWorkoutViewController
final class NewWorkoutViewController: UIViewController {

    // MARK: Types
    typealias ViewModel = NewWorkoutViewControllerModel

    // MARK: Private
    private let viewModel: ViewModel
    private var cancellables: Set<AnyCancellable> = Set()

    private var customView: NewWorkoutCustomView {
        view as! NewWorkoutCustomView
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
        view = NewWorkoutCustomView(viewModel: viewModel.customViewModel)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadNavigationItem()
        loadCustomViewBindings()
        loadViewModelBindings()
    }
}

// MARK: - Views
private extension NewWorkoutViewController {

    func loadNavigationItem() {
        navigationItem.title = "New Workout"

        let cancelAction = UIAction { [unowned self] _ in
            viewModel.didTapCancel()
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
private extension NewWorkoutViewController {

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

        customView.didSelectOptionPublisher
            .sink { [unowned self] indexPath, option in
                viewModel.didSelectOption(at: indexPath, with: option)
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
    }
}
