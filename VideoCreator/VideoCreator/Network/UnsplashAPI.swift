//
//  UnsplashAPI.swift
//  VideoCreator
//
//  Created by Pavel Boltromyuk on 25.01.23.
//

import Moya

enum UnsplashAPI {
    case random
    case search(query: String)
}

extension UnsplashAPI: TargetType {
    var baseURL: URL {
        guard let url = URL(string: "https://api.unsplash.com/") else { fatalError() }

        return url
    }

    var path: String {
        switch self {
        case .random:
            return "photos/random"
        case .search:
            return "search/photos"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var task: Moya.Task {
        switch self {
        case .random:
            return .requestParameters(parameters:
                                        [
                                            "count": Constants.maxRandomPhotos,
                                            "client_id": Constants.apiKey
                                        ],
                                      encoding: URLEncoding.queryString)
        case .search(let query):
            return .requestParameters(parameters:
                                        [
                                            "query": query,
                                            "per_page": Constants.maxPerPage,
                                            "client_id": Constants.apiKey,
                                        ],
                                      encoding: URLEncoding.queryString)
        }
    }

    var headers: [String : String]? {
        return nil
    }
}
