//
//  PlaylistView.swift
//  StewartLynch-YouTube
//
//  Created by Stewart Lynch on 2021-05-03.
//

import SwiftUI
import SDWebImageSwiftUI

struct PlaylistVideosView: View {
    @StateObject var playlistVideoVM = PlaylistVideosViewModel()
    @AppStorage("ascendingSortOrder") var ascending = true
    let selectedPlaylist: PlaylistViewModel
    var body: some View {
        List {
            ForEach(playlistVideoVM.videos) { video in
                NavigationLink(
                    destination: VideoDetailView(selectedVideo: video)) {
                    HStack(alignment: .top) {
                        WebImage(url: video.thumbnail)
                            .resizable()
                            .placeholder {
                                Image(systemName: "hourglass")
                            }
                            .scaledToFit()
                            .frame(width: 120, height: 90)
                            .mask(Rectangle().frame(width: 120, height: 66)) // Mask top and bottom black bars on thumbnail image
                        VStack(alignment: .leading) {
                            Text(video.title)
                            Spacer()
                            Text(video.publishedAt)
                                .font(.caption)
                                .padding(.bottom)
                        }
                        Spacer()
                    }
                }
            }
        }
        .frame(minWidth: 0, idealWidth: 500, maxWidth: 500)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(playlistVideoVM.playlistName)
        .navigationBarItems(trailing: Button {
            playlistVideoVM.reverseListDisplay(for: selectedPlaylist)
        } label: {
            Image(ascending ? "sortAscending" : "sortDescending")
                .resizable()
                .scaledToFit()
        }.frame(width: 30, height: 30)
        )
        .listStyle(PlainListStyle())
        .onAppear {
            playlistVideoVM.loadData(for: selectedPlaylist)
        }
    }
}

struct PlaylistVideosView_Previews: PreviewProvider {
    static var previews: some View {
        let playlist = Playlist(context: CoreDataManager.shared.viewContext)
        PlaylistVideosView(selectedPlaylist: PlaylistViewModel(playlist: playlist))
    }
}
