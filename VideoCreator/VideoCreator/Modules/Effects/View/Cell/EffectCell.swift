//
//  EffectCell.swift
//  VideoCreator
//
//  Created by Pavel Boltromyuk on 26.01.23.
//

import UIKit

class EffectCell: UICollectionViewCell {

    static let reuseIdentifer = "EffectCell"

    //MARK: - UIComponents

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        layer.borderWidth = 0
    }

    // MARK: - SetupUI

    private func setupUI() {
        backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.04)
        layer.cornerRadius = 6
        layer.borderColor = UIColor.black.cgColor
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        configureConstraints()
    }

    private func configureConstraints() {
        imageView.snp.makeConstraints { make in
            make.center.equalTo(contentView)
            make.height.width.equalTo(56)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(8)
            make.leading.trailing.equalTo(contentView).inset(16)
        }
    }

    // MARK: - Configure

    func configure(effect: Effect, isSelected: Bool = false) {
        imageView.image = effect.image
        titleLabel.text = effect.title
        configure(isSelected: isSelected)
    }

    func configure(isSelected: Bool) {
        layer.borderWidth = isSelected ? 2 : 0
    }
}
