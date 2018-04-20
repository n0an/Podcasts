//
//  APIService.swift
//  Podcasts
//
//  Created by Anton Novoselov on 20/04/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import Foundation
import Alamofire

class APIService {
    
    struct SearchResults: Decodable {
        let resultCount: Int
        let results: [Podcast]
    }
    
    static let shared = APIService()
    
    private init() {}
    
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
