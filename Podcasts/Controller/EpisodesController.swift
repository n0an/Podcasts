//
//  EpisodesController.swift
//  Podcasts
//
//  Created by Anton Novoselov on 21/04/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import UIKit
import FeedKit

class EpisodesController: UITableViewController {
    
    var podcast: Podcast! {
        didSet {
            navigationItem.title = podcast.trackName
            
            fetchEpisodes()
        }
    }
    
    fileprivate let cellId = "cellId"
    
    var episodes = [Episode]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
    }
    
    fileprivate func setupTableView() {
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
        tableView.tableFooterView = UIView()
    }
    
    fileprivate func fetchEpisodes() {
        print("Looking for episodes at feed url:", podcast?.feedUrl ?? "")
        
        guard let feedUrl = podcast?.feedUrl else { return }
        
        APIService.shared.fetchEpisodes(feedUrl: feedUrl) { (episodes) in
            self.episodes = episodes
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
        let episode = episodes[indexPath.row]
        cell.episode = episode
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 134
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let episode = self.episodes[indexPath.row]
        print("Trying to play episode:", episode.title)
        
        let window = UIApplication.shared.keyWindow
        
        let playerDetailsView = Bundle.main.loadNibNamed("PlayerDetailsView", owner: self, options: nil)?.first as! PlayerDetailsView
        
        playerDetailsView.episode = episode
        
        playerDetailsView.frame = self.view.frame
        window?.addSubview(playerDetailsView)
    }

}
