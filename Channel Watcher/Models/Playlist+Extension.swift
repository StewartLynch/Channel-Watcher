//
//  Playlist+Extension.swift
//  Channel Watcher
//
//  Created by Stewart Lynch on 2021-05-07.
//

import Foundation
import CoreData

extension Playlist: BaseModel {
    
    static func newPlaylistForChannel(playlist: Items, completion: (Playlist) -> Void) {
        let manager = CoreDataManager.shared
        let newPlaylist = Playlist(context: manager.viewContext)
        newPlaylist.playlistId = playlist.id
        newPlaylist.title = playlist.snippet.title
        newPlaylist.detail = playlist.snippet.description
        newPlaylist.thumbnail = playlist.snippet.thumbnails.default?.url
        newPlaylist.lastUpdated = Date()
        completion(newPlaylist)
    }
    
    var playlistVideos: [Video] {
        var theseVideos = videos?.allObjects as? [Video] ?? []
        return theseVideos.sorted(
            by:
                {($0.publishedAt ?? Date()).startOfDay < ($1.publishedAt ?? Date()).startOfDay},
                {$0.title ?? "" < $1.title ?? ""})
    }
    
    var videoIDs: [String] {
        let videos = videos?.allObjects as? [Video] ?? []
        return videos.map {$0.videoID ?? ""}
    }
}
