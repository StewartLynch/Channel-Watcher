//
//  APIService.swift
//  Channel Watcher
//
//  Created by Stewart Lynch on 2021-05-07.
//

import Foundation
import Combine

class APIService {
    static let shared = APIService()
    var cancellables = Set<AnyCancellable>()
    enum APIError: Error {
        case error(_ errorString: String)
    }
    
    func getJSON<T: Decodable>(urlString: String,
    dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
    keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys) -> AnyPublisher<T, APIError> {
        Future { promise in
            guard let url = URL(string: urlString) else {
                return promise(.failure(.error(NSLocalizedString("Error: Invalid URL", comment: ""))))
            }
            let request = URLRequest(url: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = dateDecodingStrategy
            decoder.keyDecodingStrategy = keyDecodingStrategy
            URLSession.shared.dataTaskPublisher(for: request)
                .map { $0.data }
                .decode(type: T.self, decoder: decoder)
                .receive(on: RunLoop.main)
                .sink { (taskCompletion) in
                    switch taskCompletion {
                    case .finished:
                        return
                    case .failure(let decodingError):
                        print("Error: \(decodingError.localizedDescription)")
                        return promise(.failure(APIError.error("Error: \(decodingError.localizedDescription)")))
                    }

                } receiveValue: { (decodedData) in
                    return promise(.success(decodedData))
                }
                .store(in: &self.cancellables)
            
        }.eraseToAnyPublisher()
    }
}

