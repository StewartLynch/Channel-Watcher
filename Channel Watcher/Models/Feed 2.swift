//
//  Playlist.swift
//  Channel Watcher
//
//  Created by Stewart Lynch on 2021-05-07.
//

import Foundation

struct Feed: Codable {
    let items: [Items]
    let pageInfo: PageInfo
    let nextPageToken: String?
}
struct PageInfo: Codable {
    let totalResults: Int
    let resultsPerPage: Int
}

struct Items: Codable, Identifiable {
    struct Snippet: Codable {
        struct Thumbnails: Codable {
            struct Default: Codable {
                let url: URL
            }
            let `default`: Default?
        }
        
        struct ResourceId: Codable {
            let videoId: String
        }
        
        let publishedAt: Date
        let title: String
        let description: String
        let thumbnails: Thumbnails
        let resourceId: ResourceId?
        let channelId: String?
    }
    
    let id: String
    let snippet: Snippet
    
}

