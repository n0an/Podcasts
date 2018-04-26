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
    
    // MARK: - PROPERTIES
    var podcast: Podcast! {
        didSet {
            navigationItem.title = podcast.trackName
            fetchEpisodes()
        }
    }
    
    fileprivate let cellId = "cellId"
    var episodes = [Episode]()
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupNavigationBarButtons()

    }
    
    // MARK: - HELPER METHODS
    fileprivate func setupNavigationBarButtons() {
        
        if UserDefaults.standard.fetchPodcasts().contains(podcast) {
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "35 heart"), style: .plain, target: self, action: nil)
            
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Favorite", style: .plain, target: self, action: #selector(handleSaveFavorite))
            
//            navigationItem.rightBarButtonItems = [
//
//                UIBarButtonItem(title: "Favorite", style: .plain, target: self, action: #selector(handleSaveFavorite)),
//                UIBarButtonItem(title: "Fetch", style: .plain, target: self, action: #selector(handleFetchSavedPodcast)),
//            ]
        }
    }
    
    @objc fileprivate func handleSaveFavorite() {
        
        guard let podcast = podcast else { return }
       
        var listOfPodcasts = UserDefaults.standard.fetchPodcasts()
        
        guard !listOfPodcasts.contains(podcast) else { return }
        
        listOfPodcasts.append(podcast)
        
        let encoder = JSONEncoder()
        
        do {
            let data = try encoder.encode(listOfPodcasts)
            UserDefaults.standard.set(data, forKey: UserDefaults.kFavoritePodcastKey)
            
            self.showBadgeHighlight()
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "35 heart"), style: .plain, target: nil, action: nil)
        
        } catch {
            print(error)
        }
    }
    
    @objc fileprivate func handleFetchSavedPodcast() {
        let listOfPodcasts = UserDefaults.standard.fetchPodcasts()
        
        listOfPodcasts.forEach { print($0.trackName ?? "") }
        
    }
    
    fileprivate func showBadgeHighlight() {
        UIApplication.mainTabBarController().viewControllers?[MainTabBarItems.favorites.rawValue].tabBarItem.badgeValue = "New"
    }
 
    
    fileprivate func setupTableView() {
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
        tableView.tableFooterView = UIView()
    }
    
    fileprivate func fetchEpisodes() {
        print("Looking for episodes at feed url:", podcast?.feedUrl ?? "")
        
        guard let feedUrl = podcast?.feedUrl else { return }
        
        APIService.shared.fetchEpisodes(feedUrl: feedUrl) { [weak self] (episodes) in
            self?.episodes = episodes
            DispatchQueue.main.async {
                self?.tableView.reloadData()
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
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let episode = self.episodes[indexPath.row]
        print("Trying to play episode:", episode.title)
        
        UIApplication.mainTabBarController().maximizePlayerDetails(episode: episode, playlistEpisodes: self.episodes)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 134
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicatorView.color = .darkGray
        activityIndicatorView.startAnimating()
        return activityIndicatorView
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return episodes.isEmpty ? 200 : 0
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let downloadAction = UITableViewRowAction(style: .normal, title: "Download") { (_, _) in
            print("downloadAction")
            
            let episode = self.episodes[indexPath.row]
            
            UserDefaults.standard.downloadEpisode(episode: episode)
            
            APIService.shared.downloadEpisode(episode: episode)
            
        }
        return [downloadAction]
    }
}












