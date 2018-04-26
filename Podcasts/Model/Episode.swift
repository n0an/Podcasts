//
//  Episode.swift
//  Podcasts
//
//  Created by Anton Novoselov on 21/04/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import Foundation
import FeedKit

struct Episode: Codable, Equatable {
    let title: String
    let pubDate: Date
    let description: String
    let author: String
    
    let streamUrl: String
    var fileUrl: String?
    
    var imageUrl: String?
    
    init(feedItem: RSSFeedItem) {
        
        self.streamUrl = feedItem.enclosure?.attributes?.url ?? ""
        
        self.title = feedItem.title ?? ""
        self.pubDate = feedItem.pubDate ?? Date()
        self.description = feedItem.iTunes?.iTunesSubtitle ?? feedItem.description ?? ""
        
        self.author = feedItem.iTunes?.iTunesAuthor ?? ""
        
        self.imageUrl = feedItem.iTunes?.iTunesImage?.attributes?.href
    }
    
}
