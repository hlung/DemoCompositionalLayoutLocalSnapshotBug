//
//  HomeCell.swift
//  TryDiffableLayoutCollectionView
//
//  Created by Kolyutsakul, Thongchai on 3/12/22.
//

import UIKit

class HomeCell: UICollectionViewCell {

  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = .black
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 36)
    return label
  }()

  private lazy var stackView: UIStackView = {
    let view = UIStackView(arrangedSubviews: [titleLabel])
    view.translatesAutoresizingMaskIntoConstraints = false
    view.axis = .vertical
    view.alignment = .center
    view.distribution = .fill
    return view
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupViews()
  }

  private func setupViews() {
    contentView.addSubview(stackView)
    self.layer.borderColor = UIColor.gray.cgColor
    self.layer.borderWidth = 1

    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
      stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
    ])
  }

}
