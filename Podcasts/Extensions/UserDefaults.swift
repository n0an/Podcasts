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
    static let kDownloadedEpisodesKey = "kDownloadedEpisodesKey"
    
    func fetchPodcasts() -> [Podcast] {
        guard let podcastData = data(forKey: UserDefaults.kFavoritePodcastKey) else { return [] }
        
        let decoder = JSONDecoder()
        
        do {
            let listOfPodcasts = try decoder.decode([Podcast].self, from: podcastData)
            
            return listOfPodcasts
            
        } catch {
            print(error)
            return []
        }
    }
    
    func fetchDownloadedEpisodes() -> [Episode] {
        
        guard let downloadedEpisodesData = data(forKey: UserDefaults.kDownloadedEpisodesKey) else { return [] }
        
        let decoder = JSONDecoder()
        
        do {
            let listOfDownloadedEpisodes = try decoder.decode([Episode].self, from: downloadedEpisodesData)
            return listOfDownloadedEpisodes
        } catch let decodeErr {
            print(decodeErr)
            return []
        }
    }
    
    func downloadEpisode(episode: Episode) {
        
        let encoder = JSONEncoder()
        
        var listOfDownloadedEpisodes = fetchDownloadedEpisodes()
        
        guard !listOfDownloadedEpisodes.contains(episode) else { return }
        
        do {
            listOfDownloadedEpisodes.insert(episode, at: 0)
            
            let episodesData = try encoder.encode(listOfDownloadedEpisodes)
            
            UserDefaults.standard.set(episodesData, forKey: UserDefaults.kDownloadedEpisodesKey)
        } catch let encErr {
            print(encErr)
        }
        
//        APIService.shared.downloadEpisode(episode: episode) { (str) in
//
//            do {
//
//                episode.fileUrl = str
//
//                listOfDownloadedEpisodes.insert(episode, at: 0)
//
//                let episodesData = try encoder.encode(listOfDownloadedEpisodes)
//
//                UserDefaults.standard.set(episodesData, forKey: UserDefaults.kDownloadedEpisodesKey)
//
//            } catch {
//                print(error)
//            }
//        }
    }
    
    func deleteEpisode(episode: Episode) {
        
        let encoder = JSONEncoder()
        
        do {
            let listOfDownloadedEpisodes = fetchDownloadedEpisodes()
            
            let filtered = listOfDownloadedEpisodes.filter { $0 != episode }
            
            let episodesData = try encoder.encode(filtered)
            
            UserDefaults.standard.set(episodesData, forKey: UserDefaults.kDownloadedEpisodesKey)
            
        } catch {
            print(error)
        }
    }
}











