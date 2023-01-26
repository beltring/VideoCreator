//
//  EffectsViewDelegate.swift
//  VideoCreator
//
//  Created by Pavel Boltromyuk on 26.01.23.
//

import UIKit

protocol EffectsViewDelegate: AnyObject {
    func didObtainEffects(effects: [Effect])
    func didDownloadPhoto(image: UIImage)
    func showErrorAlert(description: String)
}
