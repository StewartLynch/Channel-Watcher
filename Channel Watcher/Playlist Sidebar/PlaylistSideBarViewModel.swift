//
//  PlaylistSideBarViewModel.swift
//  StewartLynch On YouTube
//
//  Created by Stewart Lynch on 2021-05-06.
//

import SwiftUI
import CoreData

#warning("check to see if CD has a playlist that does not have a corresponding Feed entry")

class PlaylistSideBarViewModel: ObservableObject {
    @AppStorage("hideHidden") var hideHiddenAS = false
    @Published var selectedChannel: Channel?
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
    
    func displayPlaylists(for channel: Channel, hideHidden:Bool) -> [PlaylistViewModel] {
        return channel.channelPlaylists(hideHidden: hideHidden).map(PlaylistViewModel.init)
            .sorted(by: {$0.title < $1.title})
    }
    
    func toggleThisPlayList(thisPlaylist: PlaylistViewModel) {
        thisPlaylist.toggleHidden()
        if let channel = selectedChannel {
            playlists = displayPlaylists(for: channel, hideHidden: hideHidden)
        }
    }
    
    func loadData(channel: Channel) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        print(dateFormatter.string(from: channel.lastUpdated!))
        if channel.channelPlaylists.count == 0 {
            Channel.addAllPlaylistsFor(channel) {
                DispatchQueue.main.async { [unowned self] in
                    selectedChannel = channel
                    playlists = displayPlaylists(for: channel, hideHidden: hideHidden)
                }
            }
        } else {
            if (channel.lastUpdated ?? Date()).startOfDay < Date().startOfDay {
                updatePlaylists(for: channel) {
                    DispatchQueue.main.async { [unowned self] in
                        selectedChannel = channel
                        playlists = displayPlaylists(for: channel, hideHidden: hideHidden)
                    }
                }
            }
            DispatchQueue.main.async { [unowned self] in
                selectedChannel = channel
                playlists = displayPlaylists(for: channel, hideHidden: hideHidden)
            }
        }
    }
    
    
    func updatePlaylists(for channel: Channel, completion: @escaping () -> Void) {
        print("Checking for updated playlists")
        UpdateManager.shared.getResultsFor(fetchType: .playlists(channel.channelId!)) { result in
            switch result {
            case .success(let playlistItems):
                let manager = CoreDataManager.shared
                if let playlistItems = playlistItems {
                    // We now have all items
                    let allYTPlaylistsIds = playlistItems.map {$0.id}
                    let allCDPlaylistIds = self.playlists.map{$0.playlistId}
                    let missingPlaylistIds = allYTPlaylistsIds.difference(from: allCDPlaylistIds)
                    print("Missing playlists",missingPlaylistIds)
                    if missingPlaylistIds.isEmpty {
                        completion()
                    } else {
                        for missingPlaylistId in missingPlaylistIds {
                            // add this playlist
                            if let playlist = playlistItems.first(where: {$0.id == missingPlaylistId}) {
                                // Create a new playlist
                                if playlist.snippet.thumbnails.default != nil {
                                    Playlist.newPlaylistForChannel(playlist: playlist) { newPlaylist in
                                        channel.addToPlaylists(newPlaylist)
                                    }
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
}

