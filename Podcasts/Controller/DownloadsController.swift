//
//  DownloadsController.swift
//  Podcasts
//
//  Created by nag on 25/04/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import UIKit

class DownloadsController: UITableViewController {
    
    fileprivate let cellId = "cellId"
    
    var episodes = UserDefaults.standard.fetchDownloadedEpisodes()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        episodes = UserDefaults.standard.fetchDownloadedEpisodes()
        tableView.reloadData()
    }
    
    fileprivate func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadProgress), name: .downloadProgress, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadComplete), name: .downloadComplete, object: nil)
    }
    
    @objc fileprivate func handleDownloadProgress(notification: Notification) {
        guard let progress = notification.userInfo?["progress"] as? Double else { return }
        guard let title = notification.userInfo?["title"] as? String else { return }
        
        guard let index = self.episodes.index(where: {$0.title == title }) else { return }
        
        guard let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? EpisodeCell else { return }
        
        print(progress, title)
        
        cell.progressLabel.isHidden = progress == 1 ? true : false
        
        cell.progressLabel.text = "\(Int(progress * 100))%"
    }
    
    @objc fileprivate func handleDownloadComplete(notification: Notification) {
        guard let episodeDownloadComplete = notification.object as? APIService.EpisodeDownloadCompleteTuple else { return }
        
        guard let index = self.episodes.index(where: {$0.title == episodeDownloadComplete.episodeTitle }) else { return }

        self.episodes[index].fileUrl = episodeDownloadComplete.fileUrl
    }
    
    fileprivate func setupTableView() {
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
        cell.episode = episodes[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        UserDefaults.standard.deleteEpisode(episode: episodes[indexPath.row])
        episodes.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let episode = episodes[indexPath.row]
        
        if episode.fileUrl != nil {
            UIApplication.mainTabBarController().maximizePlayerDetails(episode: episode, playlistEpisodes: episodes)
        } else {
            let alertController = UIAlertController(title: "File URL not found", message: "Cannont find local file, play using Stream URL instead", preferredStyle: .actionSheet)
            
            alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                UIApplication.mainTabBarController().maximizePlayerDetails(episode: episode, playlistEpisodes: self.episodes)
                
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            present(alertController, animated: true)
        }
    }
}

