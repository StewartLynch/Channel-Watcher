//
//  PlaylistViewModel.swift
//  StewartLynch-YouTube
//
//  Created by Stewart Lynch on 2021-05-03.
//

import Foundation
import CoreData

class PlaylistVideosViewModel: ObservableObject {
    @Published var videos: [VideoViewModel] = []
    @Published var playlistName = ""
    var nextPageToken: String?
    var numPages:Int = 1
    func getVideos(for playlistID: NSManagedObjectID) {
        let playlist = Playlist.byId(id: playlistID) as! Playlist
        if playlist.playlistVideos.count == 0 {
            Channel.getPlaylistVideosFor(playlist) {
                DispatchQueue.main.async {
                    self.videos = playlist.playlistVideos.map(VideoViewModel.init)
                    self.playlistName = playlist.title ?? ""
                }
            }
        } else {
            videos = playlist.playlistVideos.map(VideoViewModel.init)
            playlistName = playlist.title ?? ""
        }
        
    }
}

struct VideoViewModel: Identifiable {
    
    static var dateFormatter = DateFormatter()
    let video: Video

    func updateNote() {

    }
    
    var id: NSManagedObjectID {
        video.objectID
    }
    
    var detail: String {
        video.detail ?? ""
    }
    
    var notes: String {
        video.notes ?? ""
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
