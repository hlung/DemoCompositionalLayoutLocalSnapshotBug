//
//  ViewController.swift
//  TryDiffableLayoutCollectionView
//
//  Created by Kolyutsakul, Thongchai on 2/12/22.
//

import UIKit

class ViewController: UIViewController {

  typealias Section = Int
  typealias Item = Int

  var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()

  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.automaticallyAdjustsScrollIndicatorInsets = true
    collectionView.backgroundColor = .clear
    return collectionView
  }()

  private lazy var dataSource: UICollectionViewDiffableDataSource<Section, Item> = {
    let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Int> { cell, indexPath, item in
      var contentConfiguration = cell.defaultContentConfiguration()
      contentConfiguration.text = "\(item) (random: \(Int.random(in: 1...100)))"
      cell.layer.borderWidth = 1
      cell.layer.borderColor = UIColor.gray.cgColor
      cell.contentConfiguration = contentConfiguration
    }

    return UICollectionViewDiffableDataSource<Section, Item>(
      collectionView: self.collectionView,
      cellProvider: { [weak self] (collectionView, indexPath, item) -> UICollectionViewCell? in
        guard let self = self else { return nil }
        return collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                            for: indexPath,
                                                            item: item)
      }
    )
  }()

  private lazy var layout: UICollectionViewCompositionalLayout = {
    UICollectionViewCompositionalLayout { [weak self] (sectionIndex, environment) -> NSCollectionLayoutSection? in
      guard let self = self else { return nil }

      print("layout sectionIndex \(sectionIndex)")

      // After snapshot.reloadSections

      // This can crashe with index out of bounds on section delete
      // Note: I know we are currently not using snapshotSection. This is just to simulate when we do.
      let snapshotSection = self.snapshot.sectionIdentifiers[sectionIndex]

      // Option 2
      // No crash
//      let snapshotSection = self.dataSource.snapshot().sectionIdentifiers[sectionIndex]

      let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                        heightDimension: .estimated(44)) // flexible height, min 200 px
      let item = NSCollectionLayoutItem(layoutSize: size)
      let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
      let section = NSCollectionLayoutSection(group: group)

      let isRegular = environment.traitCollection.horizontalSizeClass == .regular
      let bottomInset: CGFloat = isRegular ? 24 : 12
      section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: bottomInset, trailing: 0)
      return section
    }
  }()

  init() {
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(collectionView)

    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: view.topAnchor),
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])

    var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
    for section in 0...5 {
      snapshot.appendSections([section])
      snapshot.appendItems([section])
    }
    self.snapshot = snapshot
    dataSource.apply(snapshot)

    collectionView.delegate = self
  }

}

extension ViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let sheet = UIAlertController(title: "Menu", message: "\(indexPath)", preferredStyle: .actionSheet)

    sheet.addAction(UIAlertAction(title: "Section delete", style: .destructive, handler: { action in
      let section = self.snapshot.sectionIdentifiers[indexPath.section]

      // Option 1
      // no crash
//      var newSnapshot = self.snapshot
//      newSnapshot.deleteSections([section])
//      self.dataSource.apply(newSnapshot, animatingDifferences: false)
//      self.snapshot = newSnapshot

      // crash
      self.snapshot.deleteSections([section])
      self.dataSource.apply(self.snapshot, animatingDifferences: false)
    }))

    sheet.addAction(UIAlertAction(title: "Section reload", style: .default, handler: { action in
      let section = self.snapshot.sectionIdentifiers[indexPath.section]

      // no crash
//      var newSnapshot = self.snapshot
//      newSnapshot.reloadSections([section])
//      self.dataSource.apply(newSnapshot, animatingDifferences: false)
//      self.snapshot = newSnapshot

      // crash
      self.snapshot.reloadSections([section])
      self.dataSource.apply(self.snapshot, animatingDifferences: false)
    }))

    sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    self.present(sheet, animated: true)
  }
}
