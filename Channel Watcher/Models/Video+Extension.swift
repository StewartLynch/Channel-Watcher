//
//  Video+Extension.swift
//  Channel Watcher
//
//  Created by Stewart Lynch on 2021-05-07.
//

import Foundation
import CoreData

extension Video: BaseModel {
    
    static func byVideoId(videoId: String) -> [Video] {
        let request: NSFetchRequest<Video> = Video.fetchRequest()
        request.predicate = NSPredicate(format: "%K = %@", #keyPath(Video.videoID), videoId)
        do {
            return try viewContext.fetch(request)
        } catch {
            return []
        }
    }
    static func newVideoForPlaylist(video: Items, completion: (Video) -> Void) {
        let manager = CoreDataManager.shared
        let newVideo = Video(context: manager.viewContext)
        newVideo.videoID = video.snippet.resourceId!.videoId
        newVideo.title = video.snippet.title
        newVideo.detail = video.snippet.description
        newVideo.notes = ""
//        newVideo.publishedAt = video.snippet.publishedAt
        newVideo.publishedAt = DateFormatter.ytDateFormatter.date(from: video.snippet.publishedAtDate)
        newVideo.thumbnail = video.snippet.thumbnails.default?.url
        completion(newVideo)
    }
    
    func updateNote(_ note:String) {
        notes = note
        try? save()
    }
}
