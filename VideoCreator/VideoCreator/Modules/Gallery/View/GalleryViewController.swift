//
//  GalleryViewController.swift
//  VideoCreator
//
//  Created by Pavel Boltromyuk on 25.01.23.
//

import UIKit
import SnapKit

class GalleryViewController: UIViewController {

    private let presenter = GalleryPresenter()
    private let searchController = UISearchController(searchResultsController: nil)
    private let layout = PinterestLayout()
    private var photos = [Photo]()
    private var selectedPhotos = [String]() {
        didSet {
            showNextButtonIfNeeded()
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureSearchController()
        configurePinterestLayout()
        presenter.setViewDelegate(delegate: self)
        presenter.getRandomPhotos()
        setupUI()
    }

    // MARK: - SetupUI

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(photosCollectionView)
        view.addSubview(nextButton)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        configureConstraints()
        setupNavbar()
    }

    private func configureConstraints() {
        photosCollectionView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalTo(view)
        }

        nextButton.snp.makeConstraints { make in
            make.height.equalTo(52)
            make.leading.trailing.equalTo(view).inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(22)
        }
    }

    private func setupNavbar() {
        title = "Find photos"
        navigationController?.navigationBar.tintColor = .black
        navigationItem.backButtonTitle = ""
    }

    private func configureSearchController() {
        searchController.delegate = self
        searchController.searchBar.delegate = self
        self.navigationItem.searchController = searchController
    }

    private func configurePinterestLayout() {
        layout.columnsCount = 2
        layout.delegate = self
        layout.contentPadding = PinterestLayout.Padding(horizontal: 16, vertical: 16)
        layout.cellsPadding = PinterestLayout.Padding(horizontal: 8, vertical: 8)
    }

    // MARK: - Functions

    private func showNextButtonIfNeeded() {
        nextButton.isHidden = selectedPhotos.count < 2
    }

    // MARK: - Actions

    @objc func tappedNextButton(sender: UIButton!) {
        navigationController?.pushViewController(EffectsViewController(), animated: true)
    }

    // MARK: - UIComponents

    private lazy var photosCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.setContentOffset(.zero, animated: false)
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.reuseIdentifer)
        return collectionView
    }()

    private lazy var nextButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.layer.cornerRadius = 12
        button.isHidden = true
        button.backgroundColor = .black
        button.setTitle("Next", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.textColor = .white
        button.addTarget(self, action: #selector(tappedNextButton), for: .touchUpInside)

        return button
    }()
}

// MARK: - GalleryViewDelegate

extension GalleryViewController: GalleryViewDelegate {
    func didObtainPhotos(photos: [Photo]) {
        self.photos = photos
        photosCollectionView.reloadData()
    }

    func showErrorAlert(description: String) {
        presentAlert(title: Constants.errorTitle,
                      message: description,
                      preferredStyle: .alert,
                     cancelTitle: Constants.okTitle,
                      cancelStyle: .default,
                      animated: true
         )
    }
}

// MARK: - UISearchControllerDelegate

extension GalleryViewController: UISearchControllerDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        presenter.getRandomPhotos()
    }
}

// MARK: - UISearchBarDelegate

extension GalleryViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            return
        }
        presenter.searchPhotos(query: searchText)
    }
}

// MARK: - UICollectionViewDataSource

extension GalleryViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.reuseIdentifer, for: indexPath) as! PhotoCell
        let photo = photos[indexPath.row]
        let isSelected = selectedPhotos.contains(where: { $0 == photo.id })
        cell.configure(photoURL: photo.thumbnailUrl, isSelected: isSelected)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension GalleryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        let isNotSelected = !selectedPhotos.contains(where: { $0 == photo.id })
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCell

        if isNotSelected && selectedPhotos.count < 2 {
            cell.configure(isSelected: true)
            selectedPhotos.append(photo.id)
        } else {
            cell.configure(isSelected: false)
            selectedPhotos.removeAll { $0 == photo.id }
        }
    }
}

// MARK: - PinterestLayoutDelegate

extension GalleryViewController: PinterestLayoutDelegate {
    func cellSize(indexPath: IndexPath) -> CGSize {
        let photo = photos[indexPath.row]
        let cellWidth = Int(layout.width)
        let photoHeight = CGFloat(photo.height)
        let photoWidth = CGFloat(photo.width)
        let cellHeight = Int(photoHeight / photoWidth * layout.width)
        let size = CGSize(width: cellWidth, height: cellHeight)
        return size
    }
}
