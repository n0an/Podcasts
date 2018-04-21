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
    
    struct SearchResults: Decodable {
        let resultCount: Int
        let results: [Podcast]
    }
    
    static let shared = APIService()
    
    private init() {}
    
    func fetchEpisodes(feedUrl: String, completionHandler: @escaping ([Episode]) -> ()) {
        
        let secureFeedUrl = feedUrl.toSecureHTTPS()
        
        guard let url = URL(string: secureFeedUrl) else { return }
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
}
