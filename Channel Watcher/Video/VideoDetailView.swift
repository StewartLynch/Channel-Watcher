//
//  VideoView.swift
//  StewartLynch-YouTube
//
//  Created by Stewart Lynch on 2021-05-03.
//

import SwiftUI

struct VideoDetailView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    let video: VideoViewModel
    @State private var notes: String = ""
    var body: some View {
        GeometryReader { geo in
            VStack {
                VideoWebView(videoID: video.videoID, inline: true)
                    .frame(width: geo.size.width, height: geo.size.width * 9 / 16)
                if sizeClass == .compact {
                    VStack {
                        videoNotesView()
                    }
                } else {
                    HStack {
                        videoNotesView()
                    }
                }
                Spacer()
            }
        }
        .padding()
        .navigationTitle(video.title)
        .onAppear {
            notes = video.notes
        }
    }

    func videoNotesView() -> some View {
        Group {
            VStack {
                Text("Video Notes")
                    .padding(.vertical,3)
                    .frame(maxWidth: .infinity)
                    .background(Color(.secondarySystemBackground))
                ScrollView {
                    Text(video.detail)
                }
            }
            VStack {
                Text("My Notes")
                    .padding(.vertical,3)
                    .frame(maxWidth: .infinity)
                    .background(Color(.secondarySystemBackground))
                TextEditor(text: $notes)
            }
            .onChange(of: notes, perform: { note in
                // Save to CoreData
                let video = Video.byId(id: video.id) as! Video
                video.updateNote(note)
            })
        }
    }
}

struct VideoView_Previews: PreviewProvider {
    static var previews: some View {
        VideoDetailView(video: VideoViewModel(video: Video(context: CoreDataManager.shared.viewContext)))
    }
}
