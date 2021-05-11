//
//  StartView.swift
//  Channel Watcher
//
//  Created by Stewart Lynch on 2021-05-07.
//

import SwiftUI

struct StartView: View {
    var selectedChannel: Channel
    @Binding var showChannel:Bool
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var body: some View {
        NavigationView {
            if horizontalSizeClass == .regular {
                PlaylistSideBar(showChannel: $showChannel, selectedChannel: selectedChannel)
                VStack {
                    Text("Select a Playlist from the sidebar navigation.")
                        .font(.largeTitle)
                    Spacer()
                }.padding()
                Image("placeholderImage")
                    .resizable()
                    .scaledToFit()
            }
        else {
            PlaylistSideBar(showChannel: $showChannel, selectedChannel: selectedChannel)
            }
        }

    }
}

struct StartView_Previews: PreviewProvider {
    static let selectedChannel = Channel(context: CoreDataManager.shared.viewContext)
    static var previews: some View {
        StartView(selectedChannel: selectedChannel, showChannel: .constant(false))
    }
}
