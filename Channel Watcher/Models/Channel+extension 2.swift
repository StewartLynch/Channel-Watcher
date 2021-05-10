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
    
    static func getChannelPlayListsAndVideos(thisChannel: Channel, completion: @escaping (Bool) -> Void) {
        let manager = CoreDataManager.shared
        UpdateManager.getAllItemsFor(typeId: thisChannel.channelId!, fetchType: .playlists) { playlistItems in
            for playlist in playlistItems {
                if playlist.snippet.thumbnails.default != nil {
                    let newPlaylist = Playlist.newPlaylistForChannel(playlist: playlist)
                    thisChannel.addToPlaylists(newPlaylist)
                }
            }
            manager.save { success in
                if success {
                    let thisChannelPlaylists = thisChannel.channelPlaylists(hideHidden: false)
                    // Get all videos for each playlist
                    for playlist in thisChannelPlaylists {
                        if let playlistId = playlist.playlistId {
                            UpdateManager.getAllItemsFor(typeId: playlistId, fetchType: .videos) { videoItems in
                                for video in videoItems {
                                    if video.snippet.thumbnails.default != nil {
                                        let newVideo = Video.newVideoForPlaylist(video: video)
                                        playlist.addToVideos(newVideo)
                                    }
                                }
                                manager.save { success in
                                    completion(false)
                                }
                            }
                        }
                    }
                    completion(true)
                } else {
                    completion(false)
                }
            }
            
            
        }
        
    }
    
    static func getFirstChannel(completion: (Channel) -> Void) {
        let fetchRequest : NSFetchRequest<Channel> = Channel.fetchRequest()
        do {
            if let firstChannel = try viewContext.fetch(fetchRequest).first {
                completion(firstChannel)
            } else {
                // Need to create new entry
                let firstChannel = Channel(context: viewContext)
                firstChannel.channelId = "UCOWdR4sFkmolWkU2fg669Gg"
                firstChannel.title = "Stewart Lynch"
                do {
                    try firstChannel.save()
                    completion(firstChannel)
                } catch {
                    fatalError("Could not create last update")
                }
            }
        } catch {
            fatalError("Could not create last update")
        }
    }
    
    static func addChannel(ytChannel:YTChannel, completion: (Channel) -> Void) {
        let newChannel = Channel(context: viewContext)
        newChannel.channelId = ytChannel.items?[0].id
        newChannel.imageURL = ytChannel.items?[0].snippet.thumbnails.medium.url
        newChannel.title = ytChannel.items?[0].snippet.title
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
