//
//  PlaylistViewModel.swift
//  StewartLynch-YouTube
//
//  Created by Stewart Lynch on 2021-05-03.
//

import SwiftUI
import CoreData

class PlaylistVideosViewModel: ObservableObject {
    @AppStorage("ascendingSortOrder") var ascending = true
    @Published var videos: [VideoViewModel] = []
    @Published var playlistName = ""

    func loadData(for playlist: PlaylistViewModel) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        let thisPlaylist = Playlist.byId(id: playlist.id) as! Playlist
//        print(dateFormatter.string(from: playlist.lastUpdated))
        if thisPlaylist.playlistVideos.count == 0 {
            Channel.addAllVideosFor(thisPlaylist) {
                self.updateList(for: playlist)
            }
        } else {
            if playlist.lastUpdated.startOfDay < Date().startOfDay {
                print("Checking for new videos")
                updateVideos(for: thisPlaylist) {
                    self.updateList(for: playlist)
                }
            }
            self.updateList(for: playlist)
        }
    }
    
    func updateList(for playlist: PlaylistViewModel) {
        DispatchQueue.main.async { [unowned self] in
            videos = displayVideos(for: playlist)
            playlistName = playlist.title
        }
    }
    
    func reverseListDisplay(for playlist: PlaylistViewModel) {
        ascending.toggle()
        videos = displayVideos(for: playlist)
    }
    
    func displayVideos(for playlist: PlaylistViewModel) -> [VideoViewModel] {
        let thisPlaylist = Playlist.byId(id: playlist.id) as! Playlist
        return thisPlaylist.playlistVideos(order: ascending ? .ascending : .descending).map(VideoViewModel.init)
    }
    
    func updateVideos(for playlist: Playlist, completion: @escaping () -> Void) {
//        print("Checking for updated playlists")
        UpdateManager.shared.getResultsFor(fetchType: .videos(playlist.playlistId!)) { result in
            switch result {
            case .success(let videoItems):
                let manager = CoreDataManager.shared
                if let videoItems = videoItems {
                    // We now have all items
                    let allYTVideoIds = videoItems.map {$0.id}
                    let allCDVideoIds = self.videos.map{$0.videoID}
                    let missingVideoIds = allYTVideoIds.difference(from: allCDVideoIds)
//                    print("Missing videos",missingVideoIds)
                    if missingVideoIds.isEmpty {
                        completion()
                    } else {
                        for missingVideoId in missingVideoIds {
                            if let video = videoItems.first(where: {$0.id == missingVideoId}) {
//                                print("Adding \(video.snippet.title)")
                                // Create a new playlist
                                if video.snippet.thumbnails.default != nil {
                                    Video.newVideoForPlaylist(video: video) { newVideo in
                                        playlist.addToVideos(newVideo)
                                    }
                                }
                            } else {
                                let video = Video.byVideoId(videoId: missingVideoId).first
                                if let video = video {
//                                    print("Removing \(video.title ?? "")")
                                    try? video.delete()
                                }
                            }
                        }
                        playlist.lastUpdated = Date()
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

struct VideoViewModel: Identifiable {
    
    static var dateFormatter = DateFormatter()
    let video: Video

    var id: NSManagedObjectID {
        video.objectID
    }
    
    var detail: String {
        video.detail ?? ""
    }
    
    var notes: String {
        video.notes ?? ""
    }
    
    var isFavorite:Bool {
        video.isFavorite
    }
    
    var publishedAt: String {
        Self.dateFormatter.dateStyle = .medium
        if let publishedAt = video.publishedAt {
            return Self.dateFormatter.string(from: publishedAt)
        } else {
            return ""
        }
       
    }

    var thumbnail: URL? {
        video.thumbnail
    }
    
    var title: String {
        video.title ?? ""
    }
    
    var videoID: String {
        video.videoID ?? ""
    }

    var playerURL: URL {
        URL(string: "https://www.youtube.com/watch?v=\(video.videoID ?? "")")!
    }

}
