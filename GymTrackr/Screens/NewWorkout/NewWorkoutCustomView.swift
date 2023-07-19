//
//  NewWorkoutCustomView.swift
//  GymTrackr
//
//  Created by Sadık Kemal Sarı on 19.07.2023.
//

import Combine
import UIKit

// MARK: - NewWorkoutCustomView
final class NewWorkoutCustomView: UIView {

    // MARK: Types
    typealias ViewModel = NewWorkoutCustomViewModel
    typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, ViewModel.ItemIdentifier>
    typealias CollectionViewDiffableDataSource = UICollectionViewDiffableDataSource<
        ViewModel.SectionIdentifier,
        ViewModel.ItemIdentifier
    >

    // MARK: Internal
    var viewModel: ViewModel {
        didSet { update(for: viewModel, oldViewModel: oldValue) }
    }

    private(set) var didTapCellPublisher: PassthroughSubject<IndexPath, Never> = PassthroughSubject()
    private(set) var didChangeTextPublisher: PassthroughSubject<(IndexPath, String), Never> = PassthroughSubject()
    private(set) var didSelectOptionPublisher: PassthroughSubject<(IndexPath, Int), Never> = PassthroughSubject()

    // MARK: Private
    private var cancellables: Set<AnyCancellable> = Set()
    private var collectionViewDiffableDataSource: CollectionViewDiffableDataSource!
    private var editingCellIndexPath: IndexPath?
    private var isKeyboardShown = false
    private var isSnapshotQueued = false

    private weak var collectionView: UICollectionView!

    // MARK: Lifecycle
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        loadCollectionView()
        loadConstraints()
        loadBindings()
        update(for: viewModel, oldViewModel: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Views
private extension NewWorkoutCustomView {

    func loadCollectionView() {
        let configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        addSubview(collectionView)

        let textFieldCellRegistration = CellRegistration { [unowned self] cell, indexPath, itemIdentifier in
            cell.contentConfiguration = itemIdentifier.configuration

            let textFieldCellContentView = cell.contentView as! TextFieldCellContentView
            textFieldCellContentView.didBeginEditingTextPublisher
                .sink { [unowned self] _ in
                    editingCellIndexPath = indexPath
                }
                .store(in: &cancellables)
            textFieldCellContentView.didChangeTextPublisher
                .sink { [unowned self] text in
                    didChangeTextPublisher.send((indexPath, text))
                }
                .store(in: &cancellables)
        }

        let exerciseCellRegistration = CellRegistration { [unowned self] cell, indexPath, itemIdentifier in
            cell.contentConfiguration = itemIdentifier.configuration
            let exerciseInputCellContentView = cell.contentView as! ExerciseInputCellContentView
            exerciseInputCellContentView.clearPublishers()
            exerciseInputCellContentView.didBeginEditingTextPublisher
                .sink { [unowned self] _ in
                    editingCellIndexPath = indexPath
                }
                .store(in: &cancellables)
            exerciseInputCellContentView.didChangeTextPublisher
                .sink { [unowned self] text in
                    didChangeTextPublisher.send((indexPath, text))
                }
                .store(in: &cancellables)
            exerciseInputCellContentView.didSelectOptionPublisher
                .sink { [unowned self] option in
                    didSelectOptionPublisher.send((indexPath, option))
                }
                .store(in: &cancellables)
        }

        let buttonCellRegistration = CellRegistration { cell, _, itemIdentifier in
            cell.contentConfiguration = itemIdentifier.configuration
        }

        let diffableDataSource =
            CollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
                switch itemIdentifier {
                case .textField:
                    return collectionView.dequeueConfiguredReusableCell(
                        using: textFieldCellRegistration,
                        for: indexPath,
                        item: itemIdentifier)
                case .exercise:
                    return collectionView.dequeueConfiguredReusableCell(
                        using: exerciseCellRegistration,
                        for: indexPath,
                        item: itemIdentifier)
                case .button:
                    return collectionView.dequeueConfiguredReusableCell(
                        using: buttonCellRegistration,
                        for: indexPath,
                        item: itemIdentifier)
                }
            }

        self.collectionView = collectionView
        collectionViewDiffableDataSource = diffableDataSource
    }
}

// MARK: - Constraints
private extension NewWorkoutCustomView {

    func loadConstraints() {
        let constraints = [
            collectionView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

// MARK: - Bindings
private extension NewWorkoutCustomView {

    func loadBindings() {
        UIResponder.keyboardWillChangeFramePublisher
            .sink { [unowned self] userInfo in
                let contentInset = UIResponder.calculateContentInset(userInfo: userInfo, containerView: self)
                guard let contentInset else { return }

                collectionView.contentInset = contentInset
                collectionView.scrollIndicatorInsets = contentInset

                if let editingCell = editingCell() {
                    collectionView.scrollRectToVisible(editingCell.frame, animated: true)
                }
            }
            .store(in: &cancellables)

        UIResponder.keyboardDidHidePublisher
            .sink { [unowned self] _ in
                isKeyboardShown = false
                if isSnapshotQueued {
                    let snapshot = viewModel.snapshot()
                    collectionViewDiffableDataSource.apply(snapshot, animatingDifferences: true)
                }
            }
            .store(in: &cancellables)

        UIResponder.keyboardWillShowPublisher
            .sink { [unowned self] _ in
                isKeyboardShown = true
            }
            .store(in: &cancellables)
    }
}

// MARK: - UICollectionViewDelegate
extension NewWorkoutCustomView: UICollectionViewDelegate {

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didTapCellPublisher.send(indexPath)
    }

    func scrollViewWillBeginDragging(_: UIScrollView) {
        if let editingCellContentView = editingCellContentView() {
            editingCellContentView.resignFirstResponder()
        }
    }
}

// MARK: - Helpers
private extension NewWorkoutCustomView {

    func update(for viewModel: ViewModel, oldViewModel: ViewModel?) {
        // Applying a snapshot causes unwanted behaviors when the keyboard is shown while editing a
        // text input cell. To prevent these issues, the property isSnapshotQueued is set to true.
        // It indicates that a snapshot update should be queued and applied after the keyboard is
        // dismissed.

        let isTextInputUpdated = isTextInputUpdated(for: viewModel, oldViewModel: oldViewModel)
        if isKeyboardShown, isTextInputUpdated {
            isSnapshotQueued = true
        } else {
            let snapshot = viewModel.snapshot()
            collectionViewDiffableDataSource.apply(snapshot, animatingDifferences: true)
            isSnapshotQueued = false
        }
    }

    func isTextInputUpdated(for viewModel: ViewModel, oldViewModel: ViewModel?) -> Bool {
        let itemIdentifiers = viewModel.snapshot().itemIdentifiers
        let oldItemIdentifiers = oldViewModel?.snapshot().itemIdentifiers ?? []
        let snapshotDifference = itemIdentifiers.difference(from: oldItemIdentifiers)

        var isTextInputUpdated = false
        if let oldViewModel, let editingCellIndexPath {
            isTextInputUpdated = snapshotDifference.contains { change in
                if case .remove(offset: _, element: let itemIdentifier, associatedWith: _) = change {
                    let oldItemIdentifier = oldViewModel.collectionViewPairs[editingCellIndexPath.section]
                        .items[editingCellIndexPath.item]
                    return oldItemIdentifier == itemIdentifier
                }
                return false
            }
        }

        return isTextInputUpdated
    }

    func editingCell() -> UICollectionViewCell? {
        guard let editingCellIndexPath else { return nil }
        let editingCell = collectionView.cellForItem(at: editingCellIndexPath)
        return editingCell
    }

    func editingCellContentView() -> ExerciseInputCellContentView? {
        guard let editingCell = editingCell() else { return nil }
        let editingCellContentView = (editingCell.contentView as? ExerciseInputCellContentView)
        return editingCellContentView
    }
}
