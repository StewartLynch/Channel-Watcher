//
//  Playlist.swift
//  Channel Watcher
//
//  Created by Stewart Lynch on 2021-05-07.
//

import Foundation

struct Feed: Codable {
    let items: [Items]?
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
        
        // Unfortunately the pulishedAt date is in .iso8601 format, but sometimes has fractional seconds and sometimes not.  This is a problem for the Decodable dateDecoding strategy so I need to decode it as a string and then extract the date portion only and convert it to a date.
        let publishedAt: String
        var publishedAtDate: String {
            String(publishedAt.prefix(10))
        }
        let channelId: String?
        let title: String
        let description: String
        let thumbnails: Thumbnails
        let resourceId: ResourceId?
        let playlistId: String?

    }
    
    let id: String
    let snippet: Snippet

    
}

