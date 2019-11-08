//
//  MainTabBarController.swift
//  Podcasts
//
//  Created by Anton Novoselov on 20/04/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import UIKit

public enum MainTabBarItems: Int {
    case favorites = 0
    case search = 1
    case downloads = 2
}

class MainTabBarController: UITabBarController {
    
    // MARK: - PROPERTIES
    var maximizedTopAnchorConstraint: NSLayoutConstraint!
    var minimizedTopAnchorConstraint: NSLayoutConstraint!
    var bottomAnchorConstraint: NSLayoutConstraint!
    
    let playerDetailsView = PlayerDetailsView.initFromNib()

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        UINavigationBar.appearance().prefersLargeTitles = true
   
        tabBar.tintColor = .purple
        setupViewControllers()
        setupPlayerDetailsView()
    }
    
    // MARK: - HELPER METHODS
    fileprivate func setupPlayerDetailsView() {
        
        playerDetailsView.translatesAutoresizingMaskIntoConstraints = false
        
        view.insertSubview(playerDetailsView, belowSubview: tabBar)
        
        maximizedTopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
        maximizedTopAnchorConstraint.isActive = true
        
        minimizedTopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
        
        bottomAnchorConstraint = playerDetailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.height)
        bottomAnchorConstraint.isActive = true
        
        let constraints = [
            playerDetailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerDetailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ]
        
        constraints.forEach { $0.isActive = true }
    }
    
    fileprivate func setupViewControllers() {
        let layout = UICollectionViewFlowLayout()
        let favoritesController = FavoritesController(collectionViewLayout: layout)
        viewControllers = [
            generateNavigationController(with: favoritesController, title: "Favorites", image: #imageLiteral(resourceName: "favorites")),
            generateNavigationController(with: PodcastsSearchController(), title: "Search", image: #imageLiteral(resourceName: "search")),
            generateNavigationController(with: DownloadsController(), title: "Downloads", image: #imageLiteral(resourceName: "downloads")),
        ]
    }
    
    fileprivate func generateNavigationController(with rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController {
        
        let navController = UINavigationController(rootViewController: rootViewController)
        rootViewController.navigationItem.title = title
        
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        
        return navController
    }
    
    // MARK: - ACTIONS
    @objc func minimizePlayerDetails() {
        maximizedTopAnchorConstraint.isActive = false
        bottomAnchorConstraint.constant = view.frame.height
        minimizedTopAnchorConstraint.isActive = true
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.view.layoutIfNeeded()
            self.tabBar.transform = .identity
            
            self.playerDetailsView.maximizedStackView.alpha = 0
            self.playerDetailsView.miniPlayerView.alpha = 1
        })
    }
    
    func maximizePlayerDetails(episode: Episode? = nil, playlistEpisodes: [Episode] = []) {
        minimizedTopAnchorConstraint.isActive = false
        maximizedTopAnchorConstraint.isActive = true
        maximizedTopAnchorConstraint.constant = 0
        
        bottomAnchorConstraint.constant = 0
        
        if episode != nil {
            playerDetailsView.episode = episode
        }
        
        playerDetailsView.playlistEpisodes = playlistEpisodes
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.view.layoutIfNeeded()
            
            self.tabBar.transform = CGAffineTransform(translationX: 0, y: 100)
            
            self.playerDetailsView.maximizedStackView.alpha = 1
            self.playerDetailsView.miniPlayerView.alpha = 0
        })
    }
    
}
