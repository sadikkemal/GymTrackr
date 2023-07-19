//
//  ProgramViewController.swift
//  GymTrackr
//
//  Created by Sadık Kemal Sarı on 19.07.2023.
//

import Combine
import UIKit

// MARK: - ProgramViewController
final class ProgramViewController: UIViewController {

    // MARK: Types
    typealias ViewModel = ProgramViewControllerModel

    // MARK: Private
    private var viewModel: ViewModel
    private var cancellables: Set<AnyCancellable> = Set()

    private var customView: ProgramCustomView {
        view as! ProgramCustomView
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
        view = ProgramCustomView(viewModel: viewModel.customViewModel)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadNavigationItem()
        loadCustomViewBindings()
        loadViewModelBindings()
        viewModel.viewDidLoad()
    }
}

// MARK: - Views
private extension ProgramViewController {

    func loadNavigationItem() {
        navigationItem.title = "Program"

        let addProgramAction = UIAction { [unowned self] _ in
            viewModel.didTapAddProgram()
        }
        let addProgramBarButtonItem = UIBarButtonItem(
            systemItem: .add,
            primaryAction: addProgramAction)
        navigationItem.rightBarButtonItem = addProgramBarButtonItem
    }
}

// MARK: - Bindings
private extension ProgramViewController {

    func loadCustomViewBindings() { }

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
