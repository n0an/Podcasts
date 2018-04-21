//
//  PlayerDetailsView.swift
//  Podcasts
//
//  Created by Anton Novoselov on 21/04/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import UIKit
import AVKit

class PlayerDetailsView: UIView {
    
    @IBOutlet weak var episodeImageView: UIImageView! {
        didSet {
            episodeImageView.transform = shrunkenTransform
            episodeImageView.layer.cornerRadius = 5
            episodeImageView.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var playPauseButton: UIButton! {
        didSet {
            
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            
            playPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.numberOfLines = 2
        }
    }
    
    var episode: Episode! {
        didSet {
            titleLabel.text = episode.title
            authorLabel.text = episode.author
            
            playEpisode()
            
            guard let url = URL(string: episode.imageUrl?.toSecureHTTPS() ?? "") else { return }
            episodeImageView.sd_setImage(with: url)
        }
    }
    
    let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    fileprivate let shrunkenTransform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let time = CMTimeMake(1, 3)
        let times = [NSValue(time: time)]
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) {
            print("Episode started playing")
            self.enlargeEpisodeImageView()
        }
    }
    
    @IBAction func handleDismiss(_ sender: Any) {
        self.removeFromSuperview()
        
        
    }
    
    fileprivate func enlargeEpisodeImageView() {
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.episodeImageView.transform = .identity
        })
    }
    
    fileprivate func shrinkEpisodeImageView() {
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.episodeImageView.transform = self.shrunkenTransform
        })
    }
    
    @objc func handlePlayPause() {
        
        if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            enlargeEpisodeImageView()
        } else {
            player.pause()
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            shrinkEpisodeImageView()
        }
    }
    
    fileprivate func playEpisode() {
        print("Trying to play episode at url: ", episode.streamUrl)
        
        guard let url = URL(string: episode.streamUrl) else { return }
        let currentItem = AVPlayerItem(url: url)
        
        player.replaceCurrentItem(with: currentItem)
        player.play()
        
    }
    
    
}
