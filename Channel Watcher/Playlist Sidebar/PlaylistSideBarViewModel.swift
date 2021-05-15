//
//  PlaylistSideBarViewModel.swift
//  StewartLynch On YouTube
//
//  Created by Stewart Lynch on 2021-05-06.
//

import SwiftUI
import CoreData

class PlaylistSideBarViewModel: ObservableObject {
    @AppStorage("hideHidden") var hideHiddenAS = false
    @Published var selectedChannel: ChannelViewModel?
    @Published var playlists: [PlaylistViewModel] = []
    @Published var hideHidden:Bool = false  {
        didSet {
            hideHiddenAS = hideHidden
            if let channel = selectedChannel {
                playlists = displayPlaylists(for: channel, hideHidden: hideHidden)
            }
        }
    }
    
    init() {
        self.hideHidden = hideHiddenAS
    }
    
    func loadData(channel: ChannelViewModel) {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .full
//        print(dateFormatter.string(from: channel.lastUpdated))
        let thisChannel = Channel.byId(id: channel.id) as! Channel
        if thisChannel.channelPlaylists.count == 0 {
            Channel.addAllPlaylistsFor(thisChannel) {
                self.updateList(for: channel)
            }
        } else {
            if channel.lastUpdated.startOfDay < Date().startOfDay {
                updatePlaylists(for: thisChannel) {
                    self.updateList(for: channel)
                }
            }
            self.updateList(for: channel)
        }
    }
    
    func updateList(for channel: ChannelViewModel) {
        DispatchQueue.main.async { [unowned self] in
            selectedChannel = channel
            playlists = displayPlaylists(for: channel, hideHidden: hideHidden)
        }
    }
    
    func displayPlaylists(for channel: ChannelViewModel, hideHidden:Bool) -> [PlaylistViewModel] {
        let thisChannel = Channel.byId(id: channel.id) as! Channel
        return thisChannel.channelPlaylists(hideHidden: hideHidden).map(PlaylistViewModel.init)
            .sorted(by: {$0.title < $1.title})
    }
    
    func toggleShowHideDisabled(thisPlaylist: PlaylistViewModel) {
        thisPlaylist.toggleHidden()
        if let channel = selectedChannel {
            playlists = displayPlaylists(for: channel, hideHidden: hideHidden)
        }
    }
    
    func updatePlaylists(for channel: Channel, completion: @escaping () -> Void) {
        print("Checking for new playlists")
        UpdateManager.shared.getResultsFor(fetchType: .playlists(channel.channelId!)) { result in
            switch result {
            case .success(let playlistItems):
                let manager = CoreDataManager.shared
                if let playlistItems = playlistItems {
                    // We now have all items
                    let allYTPlaylistsIds = playlistItems.map {$0.id}
                    let CDPlaylists = channel.channelPlaylists(hideHidden: false).map(PlaylistViewModel.init)
                    let allCDPlaylistIds = CDPlaylists.map{$0.playlistId}
                    let missingPlaylistIds = allYTPlaylistsIds.difference(from: allCDPlaylistIds)
//                    print("Missing playlists",missingPlaylistIds)
                    if missingPlaylistIds.isEmpty {
                        completion()
                    } else {
                        for missingPlaylistId in missingPlaylistIds {
                            if let playlist = playlistItems.first(where: {$0.id == missingPlaylistId}) {
//                                print("Adding \(playlist.snippet.title)")
                                // Create a new playlist
                                if playlist.snippet.thumbnails.default != nil {
                                    Playlist.newPlaylistForChannel(playlist: playlist) { newPlaylist in
                                        channel.addToPlaylists(newPlaylist)
                                    }
                                }
                            } else {
                                let playlist = Playlist.byPlaylistId(playlistId: missingPlaylistId).first
                                if let playlist = playlist {
//                                    print("Removing \(playlist.title ?? "")")
                                    try? playlist.delete()
                                }
                            }
                        }
                        channel.lastUpdated = Date()
                        manager.save()
                        completion()
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

struct PlaylistViewModel: Identifiable {
    let playlist: Playlist
    
    var id: NSManagedObjectID {
        playlist.objectID
    }
    
    func toggleHidden() {
        let thisPlaylist: Playlist? = Playlist.byId(id: id) as? Playlist
        thisPlaylist?.isHidden.toggle()
        try? thisPlaylist?.save()
    }
    var title: String {
        playlist.title ?? ""
    }
    
    var detail: String {
        playlist.detail ?? ""
    }
    
    var thumbnail: URL? {
        playlist.thumbnail
    }
    
    var playlistId: String {
        playlist.playlistId ?? ""
    }
    
    var isHidden: Bool {
        playlist.isHidden
    }
    
    var lastUpdated: Date {
        playlist.lastUpdated ?? Date()
    }
}

