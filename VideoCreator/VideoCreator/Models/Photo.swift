//
//  Photo.swift
//  VideoCreator
//
//  Created by Pavel Boltromyuk on 25.01.23.
//

import Foundation

struct Photo: Decodable {
    let id: String
    let width: Int
    let height: Int
    let fullUrl: String
    let thumbnailUrl: String

    enum CodingKeys: String, CodingKey {
        case id
        case width
        case height
        case urls

        enum URLsCodingKeys: String, CodingKey {
            case fullUrl = "full"
            case thumbnailUrl = "thumb"
        }
    }

    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
        let urlsContainer = try rootContainer.nestedContainer(keyedBy: CodingKeys.URLsCodingKeys.self, forKey: .urls)

        width = try rootContainer.decode(Int.self, forKey: .width)
        height = try rootContainer.decode(Int.self, forKey: .height)
        id = try rootContainer.decode(String.self, forKey: .id)
        fullUrl = try urlsContainer.decode(String.self, forKey: .fullUrl)
        thumbnailUrl = try urlsContainer.decode(String.self, forKey: .thumbnailUrl)
    }
}
