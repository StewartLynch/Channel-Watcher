//
//  Channel+extension.swift
//  Channel Watcher
//
//  Created by Stewart Lynch on 2021-05-07.
//

import Foundation
import CoreData

extension Channel: BaseModel {
    
    func getLastLogin(completion: (Date) -> Void) {
        if let lastUpdated = lastUpdated {
            completion(lastUpdated)
        } else {
            lastUpdated = Date()
            try? save()
            completion(lastUpdated!)
        }
    }
    
    static func addAllPlaylistsFor(_ thisChannel:Channel, completion: @escaping () -> Void) {
        let manager = CoreDataManager.shared
        UpdateManager.shared.getResultsFor(fetchType: .playlists(thisChannel.channelId!)) { result in
            switch result {
            case .success(let playlistItems):
                if let playlistItems = playlistItems {
                                for playlist in playlistItems {
                                    if playlist.snippet.thumbnails.default != nil {
                                        Playlist.newPlaylistForChannel(playlist: playlist) { newPlaylist in
                                            thisChannel.addToPlaylists(newPlaylist)
                                        }
                                    }
                                }
                                manager.save()
                                completion()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    static func addAllVideosFor(_ thisPlaylist: Playlist, completion: @escaping () -> Void) {
        UpdateManager.shared.getResultsFor(fetchType: .videos(thisPlaylist.playlistId!)) { result in
            switch result {
            case .success(let videoItems):
                if let videoItems = videoItems {
                    for video in videoItems {
                        if video.snippet.thumbnails.default != nil {
                            Video.newVideoForPlaylist(video: video) { newVideo in
                                thisPlaylist.addToVideos(newVideo)
                            }
                        }
                    }
                    CoreDataManager.shared.save()
                    completion()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
            
        }
    }

    static func addChannel(item:Items, completion: (Channel) -> Void) {
        let newChannel = Channel(context: viewContext)
        newChannel.channelId = item.id
        newChannel.imageURL = item.snippet.thumbnails.default?.url
        newChannel.title = item.snippet.title
        newChannel.lastUpdated = Date()
        do {
            try newChannel.save()
            completion(newChannel)
        } catch {
            fatalError("Could not create last update")
        }
    }
    
    static func byChannelId(channelId: String) -> Channel? {
        let request:NSFetchRequest<Channel> = Channel.fetchRequest()
        request.predicate = NSPredicate(format: "%K = %@", #keyPath(Channel.channelId), channelId)
        do {
            return try viewContext.fetch(request).first
        } catch {
            print(error)
            return nil
        }
    }
    var channelPlaylists: [Playlist] {
        let thesePlaylists = playlists?.allObjects as? [Playlist] ?? []
        return thesePlaylists.sorted(
            by:
                {$0.title ?? "" < $1.title ?? ""})
    }
    
    func channelPlaylists(hideHidden:Bool) -> [Playlist] {
        var thesePlaylists = playlists?.allObjects as? [Playlist] ?? []
        if hideHidden {
            thesePlaylists = thesePlaylists.filter{$0.isHidden == false}
        }
        return thesePlaylists
    }
    
    var videoIDs: [String] {
        let playlists = playlists?.allObjects as? [Playlist] ?? []
        return playlists.map {$0.playlistId ?? ""}
    }
}
