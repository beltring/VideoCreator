//
//  PhotoCell.swift
//  VideoCreator
//
//  Created by Pavel Boltromyuk on 25.01.23.
//

import UIKit
import Kingfisher

class PhotoCell: UICollectionViewCell {
    static let reuseIdentifer = "PhotoCell"

    //MARK: - UIComponents

    private lazy var contentContainer: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 6
        return view
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
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
        imageView.snp.remakeConstraints { make in
            make.edges.equalTo(contentContainer)
        }
        imageView.layer.cornerRadius = 0
        contentContainer.layer.borderWidth = 0
    }

    private func setupUI() {
        contentView.addSubview(contentContainer)
        contentContainer.addSubview(imageView)
        setupConstraints()
    }

    private func setupConstraints() {
        contentContainer.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(contentContainer)
        }
    }

    // MARK: - Configure

    func configure(photoURL: String, isSelected: Bool = false) {
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: URL(string: photoURL))
        configure(isSelected: isSelected)
    }

    func configure(isSelected: Bool) {
        imageView.layer.cornerRadius = isSelected ? 6 : 0
        contentContainer.layer.borderWidth = isSelected ? 2 : 0
        
        if isSelected {
            imageView.snp.remakeConstraints { make in
                make.edges.equalTo(contentContainer).inset(6)
            }
        } else {
            imageView.snp.remakeConstraints { make in
                make.edges.equalTo(contentContainer)
            }
        }
    }
}
