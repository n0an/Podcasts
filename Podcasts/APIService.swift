//
//  APIService.swift
//  Podcasts
//
//  Created by Anton Novoselov on 20/04/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import Foundation
import Alamofire
import FeedKit

class APIService {
    
    typealias EpisodeDownloadCompleteTuple = (fileUrl: String?, episodeTitle: String)
    
    struct SearchResults: Decodable {
        let resultCount: Int
        let results: [Podcast]
    }
    
    static let shared = APIService()
    
    private init() {}
    
    func fetchEpisodes(feedUrl: String, completionHandler: @escaping ([Episode]) -> ()) {
        
        let secureFeedUrl = feedUrl.toSecureHTTPS()
        
        guard let url = URL(string: secureFeedUrl) else { return }
        
        DispatchQueue.global(qos: .background).async {
            let parser = FeedParser(URL: url)
            parser?.parseAsync(result: { (result) in
                print("Successfully parse feed:", result.isSuccess)

                if let err = result.error {
                    print("Failed to parse XML feed:", err)
                    return
                }

                guard let feed = result.rssFeed else { return }

                let episodes = feed.toEpisodes()
                
                completionHandler(episodes)
            })
        }
    }
    
    func fetchPodcasts(withText searchText: String, handler: @escaping (_ podcasts: [Podcast])->()) {
        let url = "https://itunes.apple.com/search"
        let params = ["term": searchText,
                      "media": "podcast"]
        
        
        Alamofire.request(url, method: .get, parameters: params, encoding: URLEncoding.default, headers: nil).responseData { (responseData) in
            
            if let err = responseData.error {
                print(err.localizedDescription)
                return
            }
            
            guard let data = responseData.data else { return }
            
            do {
                let searchResult = try JSONDecoder().decode(SearchResults.self, from: data)
                
                print("Result count: ", searchResult.resultCount)
                
                handler(searchResult.results)
                
            } catch let err {
                print("Decode err: ", err.localizedDescription)
            }
            
        }
    }
    
    func downloadEpisode(episode: Episode) {
        
        let downloadRequest = DownloadRequest.suggestedDownloadDestination()
        
        Alamofire.download(episode.streamUrl, to: downloadRequest).downloadProgress { (progress) in
            print(progress.fractionCompleted)
            
            NotificationCenter.default.post(name: .downloadProgress, object: nil, userInfo: ["title": episode.title, "progress": progress.fractionCompleted])

            }.response { (response) in
                let localUrlString = response.destinationURL?.absoluteString
                
                let episodeDownloadComplete = EpisodeDownloadCompleteTuple(localUrlString, episode.title)
                NotificationCenter.default.post(name: .downloadComplete, object: episodeDownloadComplete, userInfo: nil)
                
                
                var downloadedEpisodes = UserDefaults.standard.fetchDownloadedEpisodes()
                
                guard let index = downloadedEpisodes.index(of: episode) else { return }
                
                downloadedEpisodes[index].fileUrl = localUrlString
                
                let encoder = JSONEncoder()
                
                do {
                    let episodesData = try encoder.encode(downloadedEpisodes)
                    
                    UserDefaults.standard.set(episodesData, forKey: UserDefaults.kDownloadedEpisodesKey)
                } catch let encErr {
                    print(encErr)
                }
        }
    }
}












