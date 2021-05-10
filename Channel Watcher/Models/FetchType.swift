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
    
    var urlString: String {
        switch self {
        case .playlists(let channelId):
            return "https://youtube.googleapis.com/youtube/v3/playlists?part=snippet&channelId=\(channelId)&key=\(Constant.apiKey)"
        case .videos(let playlistId):
            return "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet%2CcontentDetails&maxResults=20&playlistId=\(playlistId)&key=\(Constant.apiKey)"
        case .id(let channelId):
            return "https://youtube.googleapis.com/youtube/v3/channels?part=snippet&id=\(channelId)&key=\(Constant.apiKey)"
            
        }
    }
}
