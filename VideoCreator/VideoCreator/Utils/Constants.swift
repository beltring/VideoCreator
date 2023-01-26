//
//  Constants.swift
//  VideoCreator
//
//  Created by Pavel Boltromyuk on 25.01.23.
//

import Foundation

struct Constants {
    static let apiKey = "MfDowYursdiA6kk0YJg0QdPB1J0RqqLi-KIbOJ5lD-c"

    static let maxRandomPhotos = 30
    static let maxPerPage = 30

    static let errorTitle = "Error"
    static let successTitle = "It's done"
    static let okButtonTitle = "OK"
    static let successDescription = "Video successfully saved to your gallery"
    static let errorDescription = "Failed to save video"

    static let defaultCornerRadius = 6

    static var LibraryURL: URL {
        return try! FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    }
}
