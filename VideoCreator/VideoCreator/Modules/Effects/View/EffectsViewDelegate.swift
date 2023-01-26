//
//  EffectsViewDelegate.swift
//  VideoCreator
//
//  Created by Pavel Boltromyuk on 26.01.23.
//

import Foundation

protocol EffectsViewDelegate: AnyObject {
    func didObtainEffects(effects: [Effect])
    func showErrorAlert(description: String)
}
