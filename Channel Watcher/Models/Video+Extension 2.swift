//
//  Video+Extension.swift
//  Channel Watcher
//
//  Created by Stewart Lynch on 2021-05-07.
//

import Foundation
import CoreData

extension Video: BaseModel {
    static func newVideoForPlaylist(video: Items) -> Video {
        let manager = CoreDataManager.shared
        let newVideo = Video(context: manager.viewContext)
        newVideo.videoID = video.snippet.resourceId!.videoId
        newVideo.title = video.snippet.title
        newVideo.detail = video.snippet.description
        newVideo.notes = ""
        newVideo.publishedAt = video.snippet.publishedAt
        newVideo.thumbnail = video.snippet.thumbnails.default?.url
        return newVideo
    }
    
    func updateNote(_ note:String) {
        notes = note
        try? save()
    }
}
