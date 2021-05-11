//
//  VideoView.swift
//  StewartLynch-YouTube
//
//  Created by Stewart Lynch on 2021-05-03.
//

import SwiftUI

struct VideoDetailView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    let selectedVideo: VideoViewModel
    @State private var myNotes = false
    @State private var notes: String = ""
    var body: some View {
        GeometryReader { geo in
            ScrollView {
            VStack {
                VideoWebView(videoID: selectedVideo.videoID, inline: true)
                    .frame(width: geo.size.width, height: geo.size.width * 9 / 16)
                Picker("Notes type", selection: $myNotes) {
                    Text("Video Notes").tag(false)
                    Text("My Notes").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                if myNotes {
                        TextEditor(text: $notes)
                } else {
                    ScrollView {
                        Text(selectedVideo.detail)
                    }
                }
                Spacer()
            }
            .onChange(of: notes, perform: { note in
                // Save to CoreData
                if notes != " " {
                    let video = Video.byId(id: selectedVideo.id) as! Video
                    video.updateNote(note)
                }
            })
            }
        }
        .padding()
        .navigationTitle(selectedVideo.title)
        .onAppear {
            notes = selectedVideo.notes
            if notes.isEmpty {
                notes = " "
            } // This is a workaround to get the notes field to be active when it is empty
        }
    }
}

struct VideoView_Previews: PreviewProvider {
    static var previews: some View {
        VideoDetailView(selectedVideo: VideoViewModel(video: Video(context: CoreDataManager.shared.viewContext)))
    }
}
