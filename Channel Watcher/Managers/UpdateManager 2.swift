//
//  UpdateManager.swift
//  Channel Watcher
//
//  Created by Stewart Lynch on 2021-05-07.
//

import Foundation

enum UpdateManager {

    static func getChannel(youtubeID: String, completion: @escaping (YTChannel) -> Void) {
        let urlString = "https://youtube.googleapis.com/youtube/v3/channels?part=snippet&id=\(youtubeID)&key=\(Constant.apiKey)"
        APIService.getJSON(urlString: urlString) { (result: Result<YTChannel, APIService.APIError>) in
            switch result {
            case .success(let ytChannel):
                completion(ytChannel)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    static func getNextBatchItems(id: String, fetchType: FetchType, nextPageToken: String? = nil, completion: @escaping ((Feed) -> Void)) {
        var urlString = fetchType == .videos ?
            "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet%2CcontentDetails&maxResults=30&playlistId=\(id)&key=\(Constant.apiKey)"
        : "https://youtube.googleapis.com/youtube/v3/playlists?part=snippet&maxResults=30&channelId=\(id)&key=\(Constant.apiKey)"
        print(urlString)
        if let nextPageToken = nextPageToken {
            urlString = urlString + "&pageToken=\(nextPageToken)"
        }
        APIService.getJSON(urlString: urlString,dateDecodingStategy: .iso8601) {  (result: Result<Feed, APIService.APIError>) in
            switch result {
            case .success(let feed):
                completion(feed)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    
    static func getAllItemsFor(typeId: String, fetchType: FetchType, completion: @escaping ([Items]) -> Void) {
        var foundItems:[Items] = []
        getNextBatchItems(id: typeId, fetchType: fetchType) { feed in
            foundItems = feed.items
            var token = feed.nextPageToken
            let nextBatchCount = Int(ceil(Double(feed.pageInfo.totalResults) / Double(feed.pageInfo.resultsPerPage)))
            if nextBatchCount > 1 {
                for _ in 1..<nextBatchCount {
                    self.getNextBatchItems(id: typeId, fetchType: fetchType, nextPageToken: token) { nextFeed in
                        foundItems += nextFeed.items
                        token = nextFeed.nextPageToken
                        completion(foundItems)
                    }
                }
            } else {
                completion(foundItems)
            }
        }
    }
}
