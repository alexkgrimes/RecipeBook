//
//  VideoPlaybackView.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 11/21/25.
//

import SwiftUI
import WebKit

struct VideoPlaybackView: UIViewRepresentable {
    let videoID: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.configuration.allowsInlineMediaPlayback = true
        webView.configuration.mediaTypesRequiringUserActionForPlayback = []
        webView.scrollView.isScrollEnabled = false
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let url = URL(string: "https://www.youtube.com/embed/\(videoID)?playsinline=1") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("https://recipebook.com", forHTTPHeaderField: "Referer")
        request.setValue("https://recipebook.com", forHTTPHeaderField: "Origin")
        uiView.load(request)
    }
}
