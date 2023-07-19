//
//  NewProgramCustomView.swift
//  GymTrackr
//
//  Created by Sadık Kemal Sarı on 19.07.2023.
//

import Combine
import UIKit

// MARK: - NewProgramCustomView
final class NewProgramCustomView: UIView {

    // MARK: Types
    typealias ViewModel = NewProgramCustomViewModel
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

    // MARK: Private
    private var collectionViewDiffableDataSource: CollectionViewDiffableDataSource!
    private var cancellables: Set<AnyCancellable> = Set()
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
private extension NewProgramCustomView {

    func loadCollectionView() {
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.headerMode = .firstItemInSection
        configuration.headerTopPadding = 18

        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        addSubview(collectionView)

        let headerRegistration = CellRegistration { [unowned self] cell, indexPath, itemIdentifier in
            if indexPath.section == 0 || indexPath.section == viewModel.collectionViewPairs.count - 1 {
                var updatedConfiguration = itemIdentifier.configuration as! UIListContentConfiguration
                updatedConfiguration.text = String()
                cell.contentConfiguration = updatedConfiguration
            } else {
                cell.contentConfiguration = itemIdentifier.configuration
            }
        }

        let textCellRegistration = CellRegistration { cell, _, itemIdentifier in
            cell.contentConfiguration = itemIdentifier.configuration
        }

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

        let buttonCellRegistration = CellRegistration { cell, _, itemIdentifier in
            cell.contentConfiguration = itemIdentifier.configuration
        }

        let diffableDataSource =
            CollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
                if indexPath.item == 0 {
                    return collectionView.dequeueConfiguredReusableCell(
                        using: headerRegistration,
                        for: indexPath,
                        item: itemIdentifier)
                } else {
                    switch itemIdentifier {
                    case .text:
                        return collectionView.dequeueConfiguredReusableCell(
                            using: textCellRegistration,
                            for: indexPath,
                            item: itemIdentifier)
                    case .textField:
                        return collectionView.dequeueConfiguredReusableCell(
                            using: textFieldCellRegistration,
                            for: indexPath,
                            item: itemIdentifier)
                    case .button:
                        return collectionView.dequeueConfiguredReusableCell(
                            using: buttonCellRegistration,
                            for: indexPath,
                            item: itemIdentifier)
                    }
                }
            }

        self.collectionView = collectionView
        collectionViewDiffableDataSource = diffableDataSource
    }
}

// MARK: - Constraints
private extension NewProgramCustomView {

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
private extension NewProgramCustomView {

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
extension NewProgramCustomView: UICollectionViewDelegate {

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
private extension NewProgramCustomView {

    func update(for viewModel: ViewModel, oldViewModel: ViewModel?) {
        let itemIdentifiers = viewModel.snapshot().itemIdentifiers
        let oldItemIdentifiers = oldViewModel?.snapshot().itemIdentifiers ?? Array()
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

        if isKeyboardShown, isTextInputUpdated {
            isSnapshotQueued = true
        } else {
            let snapshot = viewModel.snapshot()
            collectionViewDiffableDataSource.apply(snapshot, animatingDifferences: true)
            isSnapshotQueued = false
        }
    }

    func editingCell() -> UICollectionViewCell? {
        guard let editingCellIndexPath else { return nil }
        let editingCell = collectionView.cellForItem(at: editingCellIndexPath)
        return editingCell
    }

    func editingCellContentView() -> TextFieldCellContentView? {
        guard let editingCell = editingCell() else { return nil }
        let editingCellContentView = (editingCell.contentView as? TextFieldCellContentView)
        return editingCellContentView
    }
}
