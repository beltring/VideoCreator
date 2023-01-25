//
//  GalleryViewDelegate.swift
//  VideoCreator
//
//  Created by Pavel Boltromyuk on 25.01.23.
//

import Foundation

protocol GalleryViewDelegate: AnyObject {
    func didObtainPhotos(photos: [Photo])
    func showErrorAlert(description: String)
}
