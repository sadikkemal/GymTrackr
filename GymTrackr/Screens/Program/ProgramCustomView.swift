//
//  ProgramCustomView.swift
//  GymTrackr
//
//  Created by Sadık Kemal Sarı on 19.07.2023.
//

import Combine
import UIKit

// MARK: - ProgramCustomView
final class ProgramCustomView: UIView {

    // MARK: Types
    typealias ViewModel = ProgramCustomViewModel
    typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, ViewModel.ItemIdentifier>
    typealias CollectionViewDiffableDataSource = UICollectionViewDiffableDataSource<
        ViewModel.SectionIdentifier,
        ViewModel.ItemIdentifier
    >

    // MARK: Internal
    var viewModel: ViewModel {
        didSet { update(for: viewModel) }
    }

    private(set) var didTapCellPublisher: PassthroughSubject<IndexPath, Never> = PassthroughSubject()

    // MARK: Private
    private weak var collectionView: UICollectionView!
    private var collectionViewDiffableDataSource: CollectionViewDiffableDataSource!

    // MARK: Lifecycle
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        loadCollectionView()
        loadConstraints()
        update(for: viewModel)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Views
private extension ProgramCustomView {

    func loadCollectionView() {
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.headerMode = .firstItemInSection
        configuration.headerTopPadding = 18

        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        addSubview(collectionView)

        let headerRegistration = CellRegistration { cell, _, itemIdentifier in
            cell.contentConfiguration = itemIdentifier.configuration
            cell.accessories = [.outlineDisclosure(options: UICellAccessory.OutlineDisclosureOptions(style: .header))]
        }

        let cellRegistration = CellRegistration { cell, _, itemIdentifier in
            cell.contentConfiguration = itemIdentifier.configuration
//            cell.accessories = [.label(text: "Start")]
        }

        let diffableDataSource =
            CollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
                if indexPath.item == 0 {
                    return collectionView.dequeueConfiguredReusableCell(
                        using: headerRegistration,
                        for: indexPath,
                        item: itemIdentifier)
                } else {
                    return collectionView.dequeueConfiguredReusableCell(
                        using: cellRegistration,
                        for: indexPath,
                        item: itemIdentifier)
                }
            }

        self.collectionView = collectionView
        collectionViewDiffableDataSource = diffableDataSource
    }
}

// MARK: - Constraints
private extension ProgramCustomView {

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

// MARK: - Helpers
private extension ProgramCustomView {

    func update(for viewModel: ViewModel) {
        let snapshot = viewModel.snapshot()
        collectionViewDiffableDataSource.apply(snapshot, animatingDifferences: true)

        for (section, sectionSnapshot) in viewModel.sectionSnapshots() {
            collectionViewDiffableDataSource.apply(sectionSnapshot, to: section)
        }
    }
}

// MARK: - UICollectionViewDelegate
extension ProgramCustomView: UICollectionViewDelegate {

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didTapCellPublisher.send(indexPath)
    }
}
