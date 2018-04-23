//
//  UserDefaults.swift
//  Podcasts
//
//  Created by Anton Novoselov on 23/04/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import UIKit

extension UserDefaults {
    
    static let kFavoritePodcastKey = "kFavoritePodcastKey"
    
    func fetchPodcasts() -> [Podcast] {
        guard let podcastData = UserDefaults.standard.value(forKey: UserDefaults.kFavoritePodcastKey) as? Data else { return [] }
        
        let decoder = JSONDecoder()
        
        do {
            let listOfPodcasts = try decoder.decode([Podcast].self, from: podcastData)
            
            return listOfPodcasts
            
        } catch {
            print(error)
            return []
        }
    }
}
