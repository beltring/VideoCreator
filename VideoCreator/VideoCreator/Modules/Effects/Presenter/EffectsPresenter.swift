//
//  EffectsPresenter.swift
//  VideoCreator
//
//  Created by Pavel Boltromyuk on 26.01.23.
//

import Foundation
import Kingfisher

class EffectsPresenter {

    weak private var delegate: EffectsViewDelegate?
    private let effects = [
        Effect(title: "Screwing", imageName: "screwing"),
        Effect(title: "From right to left", imageName: "arrowRight")
    ]

    func setViewDelegate(delegate: EffectsViewDelegate?) {
        self.delegate = delegate
    }

    // Тут может быть вызов апи для получения эффектов
    func obtainEffects() {
        delegate?.didObtainEffects(effects: effects)
    }

    func downloadImage(photo: Photo) {
        guard let url = URL(string: photo.fullUrl) else { return }
        KingfisherManager.shared.retrieveImage(with: url) { [weak self] result in
            switch result {
            case .success(let retrieveResult):
//                let image: UIImage = retrieveResult.image
                self?.delegate?.didDownloadPhoto(image: retrieveResult.image)
            case .failure(let error):
                self?.delegate?.showErrorAlert(description: error.localizedDescription)
            }
        }
    }
}
