//
//  PhotoList.swift
//  VideoCreator
//
//  Created by Pavel Boltromyuk on 25.01.23.
//

import Foundation

struct PhotoList: Decodable {
    let total: Int
    let totalPages: Int
    let photos: [Photo]

    enum CodingKeys: String, CodingKey {
        case total
        case totalPages = "total_pages"
        case photos = "results"
    }
}
