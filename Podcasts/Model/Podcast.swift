//
//  Podcast.swift
//  Podcasts
//
//  Created by Anton Novoselov on 20/04/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import Foundation

struct Podcast: Codable, Equatable {
    var trackName: String?
    var artistName: String?
    var artworkUrl600: String?
    var trackCount: Int?
    var feedUrl: String?
}
