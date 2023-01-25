//
//  GalleryPresenter.swift
//  VideoCreator
//
//  Created by Pavel Boltromyuk on 25.01.23.
//

import Foundation

class GalleryPresenter {

    weak private var delegate: GalleryViewDelegate?

    func setViewDelegate(delegate: GalleryViewDelegate?) {
        self.delegate = delegate
    }

    func getPhotos() {
    }
}
