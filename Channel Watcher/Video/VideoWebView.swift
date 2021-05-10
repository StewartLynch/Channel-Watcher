//
//  WebView.swift
//  Embed Video
//
//  Created by Stewart Lynch on 2021-05-04.
//

import SwiftUI
import WebKit

struct VideoWebView: UIViewRepresentable {
    let videoID: String
    let inline: Bool
    
    func makeUIView(context: Context) -> WKWebView {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs
        config.allowsInlineMediaPlayback = inline
        config.mediaTypesRequiringUserActionForPlayback = []
        
        return WKWebView(frame: .zero, configuration: config)
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {

        guard let  myURL = URL(string: "https://www.youtube.com/embed/\(videoID)?playsinline=1") else {
            return
        }
        let request = URLRequest(url: myURL)
        uiView.load(request)
    }
    
    
}
