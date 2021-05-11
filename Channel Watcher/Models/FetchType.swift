//
//  FetchType.swift
//  Channel Watcher
//
//  Created by Stewart Lynch on 2021-05-07.
//

import Foundation


enum FetchType {
    case playlists(String)
    case videos(String)
    case id(String)
    case userName(String)
    
    var urlString: String {
        switch self {
        case .playlists(let channelId):
            return "https://youtube.googleapis.com/youtube/v3/playlists?part=snippet&maxResults=50&channelId=\(channelId.removingSpaces)&key=\(Constant.apiKey)"
        case .videos(let playlistId):
            return "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet%2CcontentDetails&maxResults=50&playlistId=\(playlistId.removingSpaces)&key=\(Constant.apiKey)"
        case .id(let channelId):
            return "https://youtube.googleapis.com/youtube/v3/channels?part=snippet&id=\(channelId.removingSpaces)&key=\(Constant.apiKey)"
        case .userName(let userName):
            return "https://youtube.googleapis.com/youtube/v3/channels?part=snippet&forUsername=\(userName.removingSpaces)&key=\(Constant.apiKey)"
        }
    }
}
