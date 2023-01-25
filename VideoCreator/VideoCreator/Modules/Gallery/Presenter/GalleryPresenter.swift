//
//  GalleryPresenter.swift
//  VideoCreator
//
//  Created by Pavel Boltromyuk on 25.01.23.
//

import Foundation

class GalleryPresenter {

    private let networkManager = NetworkManager()
    weak private var delegate: GalleryViewDelegate?

    func setViewDelegate(delegate: GalleryViewDelegate?) {
        self.delegate = delegate
    }

    func getRandomPhotos() {
        networkManager.fetchRandomPhotos { [weak self] result in
            switch result {
            case .success(let photos):
                self?.delegate?.didObtainPhotos(photos: photos)
            case .failure(let error):
                self?.delegate?.showErrorAlert(description: error.localizedDescription)
            }
        }
    }

    func searchPhotos(query: String) {
        networkManager.searchPhotos(query: query) { [weak self] result in
            switch result {
            case .success(let photoList):
                self?.delegate?.didObtainPhotos(photos: photoList.photos)
            case .failure(let error):
                self?.delegate?.showErrorAlert(description: error.localizedDescription)
            }
        }
    }
}
