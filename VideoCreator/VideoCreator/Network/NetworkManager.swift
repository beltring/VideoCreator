//
//  NetworkManager.swift
//  VideoCreator
//
//  Created by Pavel Boltromyuk on 25.01.23.
//

import Moya

final class NetworkManager {
    private var provider = MoyaProvider<UnsplashAPI>()

    func fetchRandomPhotos(completion: @escaping (Result<[Photo], Error>) -> ()) {
        request(target: .random, completion: completion)
    }

    func searchPhotos(query: String, completion: @escaping (Result<PhotoList, Error>) -> ()) {
        request(target: .search(query: query), completion: completion)
    }

    private func request<T: Decodable>(target: UnsplashAPI, completion: @escaping (Result<T, Error>) -> ()) {
        provider.request(target) { result in
            switch result {
            case let .success(response):
                do {
                    let results = try JSONDecoder().decode(T.self, from: response.data)
                    completion(.success(results))
                } catch let error {
                    completion(.failure(error))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
