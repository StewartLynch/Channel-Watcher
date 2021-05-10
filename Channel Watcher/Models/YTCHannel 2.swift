//
//  ChannelYT.swift
//  Channel Watcher
//
//  Created by Stewart Lynch on 2021-05-05.
//

import Foundation

struct YTChannel: Codable {
  struct Items: Codable {
    struct Snippet: Codable {
      struct Thumbnails: Codable {
        struct Medium: Codable {
          let url: URL
        }
        let medium: Medium
      }
      let title: String
      let description: String
      let thumbnails: Thumbnails
    }
    let id: String
    let snippet: Snippet
  }

  let items: [Items]?
}
