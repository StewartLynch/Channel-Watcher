//
//  ChannelPickerViewModel.swift
//  Channel Watcher
//
//  Created by Stewart Lynch on 2021-05-05.
//

import SwiftUI
import CoreData

class ChannelPickerViewModel: ObservableObject {
    @Published var channels: [ChannelViewModel] = []
    @Published var youtubeID: String = ""
    @Published var alertType: AlertType? = nil
    func getAllChannels() {
        channels = Channel.all().map(ChannelViewModel.init).sorted(by: {$0.title < $1.title})
    }
    
    func addChannel(youtubeID: String) {
        UpdateManager.getChannel(youtubeID: youtubeID) { ytChannel in
            if let _ = ytChannel.items {
                if let _ = Channel.byChannelId(channelId: (ytChannel.items?[0].id)!) {
                    DispatchQueue.main.async {
                        self.alertType = AlertType.singleButton(
                            title: "Duplicate",
                            message: "You already have the channel for id: \(youtubeID)",
                            dismissButton: Alert.Button.default(Text("OK")) {
                                DispatchQueue.main.async {
                                    self.youtubeID = ""
                                }
                            })
                    }
                } else {
                    self.addNewChannel(ytChannel: ytChannel)
                }
            } else {
                DispatchQueue.main.async {
                    self.alertType = AlertType.singleButton(
                        title: "No Channel",
                        message: "There is no channel for this id",
                        dismissButton: Alert.Button.default(Text("OK")) {
                            DispatchQueue.main.async {
                                self.youtubeID = ""
                            }
                        })
                }
            }
        }
    }
    
    func addNewChannel(ytChannel: YTChannel) {
        Channel.addChannel(ytChannel: ytChannel) { channel in
            Channel.getChannelPlayListsAndVideos(thisChannel: channel) { success in
                if success {
                    DispatchQueue.main.async {
                        self.channels.append(ChannelViewModel(channel: channel))
                        self.youtubeID = ""
                    }
                } else {
                    DispatchQueue.main.async {
                        self.alertType = AlertType.singleButton(
                            title: "Error Adding Channel",
                            message: "There was a problem adding this channel.  Please delete and try again.",
                            dismissButton: Alert.Button.default(Text("OK")) {
                            })
                    }
                }
            }
                
        }
    }
        
    func deleteChannel(channel: ChannelViewModel) {
        let channelToDelete = Channel.byId(id: channel.id) as! Channel
        try? channelToDelete.delete()
        getAllChannels()
    }
}


struct ChannelViewModel: Identifiable {
    let channel: Channel
    var id: NSManagedObjectID {
        channel.objectID
    }
    
    var title: String {
        channel.title ?? ""
    }
    
    var channelId: String {
        channel.channelId ?? ""
    }
    
    var lastUpdated: Date {
        channel.lastUpdated ?? Date()
    }
    
    var imageURL: URL? {
        channel.imageURL
    }
}
