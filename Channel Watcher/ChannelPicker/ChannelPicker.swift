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
    @State private var selectedChannel: ChannelViewModel?
    @State private var showChannel = false
    @State private var byId = true
    @State private var catalyst = false
    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    VStack {
                        Picker("Search Type", selection: $byId) {
                            Text("Channel Id").tag(true)
                            Text("Channel Name").tag(false)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        HStack(alignment: .center) {
                            TextField(byId ? "Enter Channel ID" : "Enter Channel name", text: $channelPickerVM.youtubeID)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Button {
                                channelPickerVM.addChannel(youtubeID: channelPickerVM.youtubeID, byId: byId)
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                            }
                            .padding(.vertical)
                            .disabled(channelPickerVM.youtubeID.isEmpty)
                        }
                        Text("Watched Channels")
                            .font(.title)
                            .onTapGesture {
                                UIApplication.shared.endEditing()
                            }
                    }
                    .frame(width: 300)
                    List {
                        Section(header: Text("Channels")) {
                            if channelPickerVM.channels.isEmpty {
                                Text("Add some channels")
                            }
                            ForEach(channelPickerVM.channels) { channel in
                                Button {
                                    selectedChannel = channel
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
                    Spacer()
                }
                .navigationTitle("Channel Watcher")
                .navigationBarItems(trailing: editButtonOrEmtyView()) // Only show edit button on MacCatalyst
                .frame(minWidth: 300, maxWidth: 400)
                .listStyle(PlainListStyle())
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
            #if targetEnvironment(macCatalyst)
                catalyst = true
            #else
                catalyst = false
            #endif
            if Constant.apiKey == "" {
                channelPickerVM.alertType = .ok(title: "API Key Missing", message: "You need to add yor API Key to the Constants file")
            }
        }
        .alert(item: $channelPickerVM.alertType) { $0.alert}
    }
}

extension ChannelPicker {
    @ViewBuilder func editButtonOrEmtyView() -> some View {
        if catalyst {
            EditButton()
        } else {
            EmptyView()
        }
    }
}

struct ChannelPicker_Previews: PreviewProvider {
    static var previews: some View {
        ChannelPicker()
    }
}
