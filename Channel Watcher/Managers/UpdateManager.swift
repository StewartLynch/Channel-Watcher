//
//  UpdateManager.swift
//  Channel Watcher
//
//  Created by Stewart Lynch on 2021-05-07.
//

import Foundation
import Combine

class UpdateManager {
    static let shared = UpdateManager()
    var cancellables = Set<AnyCancellable>()
    func resultsPublisher(urlString: String) -> AnyPublisher<[Items]?, APIService.APIError> {
        print(urlString)
        let pageIndexPublisher = CurrentValueSubject<String,APIService.APIError>(urlString)
        let apiService = APIService.shared
        return pageIndexPublisher.flatMap { token in
            return apiService.getJSON(urlString: pageIndexPublisher.value,
                                      dateDecodingStrategy: .iso8601)
        }
        .handleEvents(receiveOutput: { (feed: Feed) in
            if feed.nextPageToken != nil {
                let newUrlString = urlString + "&pageToken=\(feed.nextPageToken!)"
                pageIndexPublisher.send(newUrlString)
            } else {
                pageIndexPublisher.send(completion: .finished)
            }
        })
        .reduce([Items](), { allItems, feed in
            if let feedItems = feed.items {
                return allItems! + feedItems
            } else {
                return nil
            }
        })
        .eraseToAnyPublisher()
    }
    
    func getResultsFor(fetchType: FetchType, functionCompletion: @escaping (Result<[Items]?,APIService.APIError>) -> Void) {
        let urlString = fetchType.urlString
        resultsPublisher(urlString: urlString)
            .sink { completion in
                switch completion{
                case .finished:
                    print("Retrieved all Results")
                case .failure(let error):
                    // Show alert here in case there is an error
                    functionCompletion(.failure(error))
                }
            } receiveValue: { items in
                functionCompletion(.success(items))
            }
            .store(in: &cancellables)
    }
    
}
