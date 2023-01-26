//
//  EffectsPresenter.swift
//  VideoCreator
//
//  Created by Pavel Boltromyuk on 26.01.23.
//

import Foundation

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
}
