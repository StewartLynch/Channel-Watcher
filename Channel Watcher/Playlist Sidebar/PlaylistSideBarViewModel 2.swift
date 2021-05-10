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
            DispatchQueue.main.async { [unowned self] in
                selectedChannel = channel
                playlists = displayPlaylists(for: channel, hideHidden: hideHidden)
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

