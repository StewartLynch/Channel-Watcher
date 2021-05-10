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
        UpdateManager.shared.getResultsFor(fetchType: FetchType.id(youtubeID)) { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let items):
                if let items = items {
                    if let _ = Channel.byChannelId(channelId: (items[0].id)) {
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
                        self.addNewChannel(item: items[0])
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
    }
    
    func addNewChannel(item: Items) {
        Channel.addChannel(item: item) { channel in
            DispatchQueue.main.async {
                self.channels.append(ChannelViewModel(channel: channel))
                self.getAllChannels()
                self.youtubeID = ""
            }
        }
    }
    
    func deleteChannel(channel: ChannelViewModel) {
        let channelToDelete = Channel.byId(id: channel.id) as! Channel
        try? channelToDelete.delete()
        getAllChannels()
    }
    
    func getPlayLists(channel: Channel, completion: () -> Void) {
        print(channel.channelPlaylists.count)
        completion()
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
