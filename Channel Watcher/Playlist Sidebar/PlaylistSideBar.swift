//
//  PlaylistSideBar.swift
//  StewartLynch On YouTube
//
//  Created by Stewart Lynch on 2021-05-06.
//

import SwiftUI
import SDWebImageSwiftUI

struct PlaylistSideBar: View {
    @StateObject var playlistSBVM = PlaylistSideBarViewModel()
    @State private var alertType: AlertType?
    @Binding var showChannel: Bool
    var selectedChannel:ChannelViewModel
    var body: some View {
            Group {
                if let _ = playlistSBVM.selectedChannel {
                    VStack(spacing: 0) {
                        Button("Switch Channels") {
                            withAnimation {
                                showChannel = false
                            }
                        }
                    List {
                        ForEach(playlistSBVM.playlists) { playlist in
                            NavigationLink(
                                destination:
                                    PlaylistVideosView(selectedPlaylist: playlist),
                                label: {
                                    HStack {
                                        WebImage(url: playlist.thumbnail)
                                            .resizable()
                                            .placeholder {
                                                Image(systemName: "hourglass")
                                            }
                                            .scaledToFit()
                                            .frame(width: 60, height: 45)
                                            .mask(Rectangle().frame(width: 60, height: 33)) // Mask top and bottom black bars on thumbnail image
                                        Text(playlist.title)
                                        Spacer()
                                        Button {
                                            playlistSBVM.toggleShowHideDisabled(thisPlaylist: playlist)
                                        } label: {
                                            Image(systemName: playlist.isHidden ? "eye.fill" : "slash.circle")
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                    .foregroundColor(playlist.isHidden ? Color.secondary : Color.primary)
                                })

                        }
                    }
                    .listStyle(SidebarListStyle())
                }
                    .navigationBarItems(trailing: Button {
                        playlistSBVM.hideHidden.toggle()
                    } label: {
                        Text( playlistSBVM.hideHidden ? "Show Disabled" : "Hide Disabled")
                    })
                    .navigationTitle("Playlists")
                } else {
                    Text("Loading data...")
                }
            }
            .alert(item: $alertType) { $0.alert}
            .onAppear{
                playlistSBVM.loadData(channel: selectedChannel)
            }
    }
}

//struct PlaylistSideBar_Previews: PreviewProvider {
//    static var previews: some View {
//        PlaylistSideBar()
//    }
//}
