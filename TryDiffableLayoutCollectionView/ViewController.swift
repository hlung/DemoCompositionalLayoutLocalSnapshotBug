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

  private let cellReuseIdentifier = "HomeCell"

  private lazy var dataSource: UICollectionViewDiffableDataSource<Section, Item> = {
    return UICollectionViewDiffableDataSource<Section, Item>(
      collectionView: self.collectionView,
      cellProvider: { [weak self] (collectionView, indexPath, item) -> UICollectionViewCell? in
        guard let self = self else { return nil }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellReuseIdentifier, for: indexPath)
        if let cell = cell as? HomeCell {
          cell.titleLabel.text = "\(item)"
        }
        return cell
      }
    )
  }()

  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.automaticallyAdjustsScrollIndicatorInsets = true
    collectionView.backgroundColor = .clear
    return collectionView
  }()

  private lazy var layout: UICollectionViewCompositionalLayout = {
    UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in

      // After snapshot.reloadSections

      // This crashes
      let snapshotSection = self.snapshot.sectionIdentifiers[sectionIndex]

      // This does NOT crash
//      let snapshotSection = self.dataSource.snapshot().sectionIdentifiers[sectionIndex]

      let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                        heightDimension: .estimated(44)) // flexible height, min 200 px
      let item = NSCollectionLayoutItem(layoutSize: size)
      let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
      let section = NSCollectionLayoutSection(group: group)

      let isRegular = environment.traitCollection.horizontalSizeClass == .regular
      let bottomInset: CGFloat = isRegular ? 24 : 12
      section.contentInsets = NSDirectionalEdgeInsets(top: 0,
                                                      leading: 0,
                                                      bottom: bottomInset,
                                                      trailing: 0)
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

    collectionView.register(HomeCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
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
      snapshot.appendItems([section * 10])
    }
    self.snapshot = snapshot
    dataSource.apply(snapshot)

    collectionView.delegate = self
  }

}

extension ViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let sheet = UIAlertController(title: "Menu", message: "\(indexPath)", preferredStyle: .actionSheet)

    sheet.addAction(UIAlertAction(title: "Section reload", style: .default, handler: { action in
      let section = self.snapshot.sectionIdentifiers[indexPath.section]
      self.snapshot.reloadSections([section])
    }))

    sheet.addAction(UIAlertAction(title: "Section delete", style: .destructive, handler: { action in
      let section = self.snapshot.sectionIdentifiers[indexPath.section]
      self.snapshot.deleteSections([section])
      self.dataSource.apply(self.snapshot, animatingDifferences: false)
    }))

    sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    self.present(sheet, animated: true)
  }
}
