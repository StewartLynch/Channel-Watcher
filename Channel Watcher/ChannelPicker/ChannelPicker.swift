//
//  ContentView.swift
//  Channel Watcher
//
//  Created by Stewart Lynch on 2021-05-05.
//

import SwiftUI
import SDWebImageSwiftUI

struct ChannelPicker: View {
    @StateObject var channelPickerVM = ChannelPickerViewModel()
    @State private var selectedChannel: Channel?
    @State private var showChannel = false
    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    Text("Your Watched Channels")
                        .font(.title)
                        .padding(.top, 40)
                    HStack(alignment: .center) {
                        TextField("Enter Channel ID", text: $channelPickerVM.youtubeID)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.top)
                        Button {
                            channelPickerVM.addChannel(youtubeID: channelPickerVM.youtubeID)
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                        }
                        .disabled(channelPickerVM.youtubeID.isEmpty)
                    }
                    .frame(width: 300)
                    .padding(.vertical)
                    List {
                        Section(header: Text("Channels")) {
                            if channelPickerVM.channels.isEmpty {
                                Text("Add some channels")
                            }
                            ForEach(channelPickerVM.channels) { channel in
                                Button {
                                    selectedChannel = Channel.byId(id: channel.id) as? Channel
                                    withAnimation {
                                        showChannel = true
                                    }
                                } label: {
                                    HStack {
                                        WebImage(url: channel.imageURL)
                                            .resizable()
                                            .placeholder {
                                                Image(systemName: "hourglass")
                                            }
                                            .scaledToFit()
                                            .frame(width: 60, height: 60)
                                            .cornerRadius(10)
                                        Text(channel.title)
                                    }
                                }
                            }
                            .onDelete(perform: { indexSet in
                                indexSet.forEach { index in
                                    let channel = channelPickerVM.channels[index]
                                    channelPickerVM.deleteChannel(channel: channel)
                                }
                            })
                        }
                    }
                }
                .navigationTitle("Channel Watcher")
                .frame(width: 400)
                .listStyle(GroupedListStyle())
                .padding()
            }
            .navigationViewStyle(StackNavigationViewStyle()) // prevent split view from happening here
            if showChannel {
                StartView(selectedChannel: selectedChannel!,showChannel: $showChannel)
                    .transition(.scale)
            }
        }
        .onAppear {
            channelPickerVM.getAllChannels()
        }
        .alert(item: $channelPickerVM.alertType) { $0.alert}
    }
}

struct ChannelPicker_Previews: PreviewProvider {
    static var previews: some View {
        ChannelPicker()
    }
}
