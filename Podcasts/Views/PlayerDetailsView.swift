//
//  PlayerDetailsView.swift
//  Podcasts
//
//  Created by Anton Novoselov on 21/04/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer

class PlayerDetailsView: UIView {
    
    // MARK: - OUTLETS
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
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var currentTimeSlider: UISlider!
    
    @IBOutlet weak var miniEpisodeImageView: UIImageView!
    @IBOutlet weak var miniTitleLabel: UILabel!
    
    @IBOutlet weak var miniPlayPauseButton: UIButton! {
        didSet {
            miniPlayPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
            miniPlayPauseButton.imageEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        }
    }
    
    @IBOutlet weak var miniFastForwardButton: UIButton! {
        didSet {
            miniFastForwardButton.imageEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
            miniFastForwardButton.addTarget(self, action: #selector(handleFastForward(_:)), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var miniPlayerView: UIView!
    @IBOutlet weak var maximizedStackView: UIStackView!
    
    // MARK: - PROPERTIES
    var episode: Episode! {
        didSet {
            miniTitleLabel.text = episode.title
            
            titleLabel.text = episode.title
            authorLabel.text = episode.author
            
            setupNowPlayingInfo()
            
            setupAudioSessions()
            
            playEpisode()
            
            guard let url = URL(string: episode.imageUrl?.toSecureHTTPS() ?? "") else { return }
            episodeImageView.sd_setImage(with: url)
            
            miniEpisodeImageView.sd_setImage(with: url) { (image, _, _, _) in
                
                guard let image = image else { return }
                
                var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
                
                let artwork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { (_) -> UIImage in
                    return image
                })
                
                nowPlayingInfo?[MPMediaItemPropertyArtwork] = artwork
                
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            }
        }
    }
    
    let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    fileprivate let shrunkenTransform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    
    var playlistEpisodes = [Episode]()
    
    // MARK: - awakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        setupAudioSessions()
        setupRemoteControl()
        
        setupGestures()
        
        setupInterruptionObserver()
        
        observePlayerCurrentTime()
        
        observeBoundaryTime()
    }
    
    static func initFromNib() -> PlayerDetailsView {
        return Bundle.main.loadNibNamed("PlayerDetailsView", owner: self, options: nil)?.first as! PlayerDetailsView
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .AVAudioSessionInterruption, object: nil)
    }
    
    // MARK: - HELPER METHODS
    func setupInterruptionObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: .AVAudioSessionInterruption, object: nil)
    }
    
    @objc fileprivate func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        guard let type = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt else { return }
        
        if type == AVAudioSessionInterruptionType.began.rawValue {
            print("Interruption began")
            
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)

        } else {
            print("Interruption ended")
            
            guard let options = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            
            if options == AVAudioSessionInterruptionOptions.shouldResume.rawValue {
                player.play()
                
                playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
                miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            }
            
        }
        
    }
    
    fileprivate func observeBoundaryTime() {
        let time = CMTimeMake(1, 3)
        let times = [NSValue(time: time)]
        
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [unowned self] in
            
            
            print("Episode started playing")
            self.enlargeEpisodeImageView()
            self.setupLockscreenCurrentTime()
        }
    }
    
    fileprivate func setupNowPlayingInfo() {
        
        var nowPlayingInfo = [String: Any]()
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = episode.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = episode.author
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    fileprivate func setupRemoteControl() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        let commandCenter =  MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.isEnabled = true
        
        commandCenter.playCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            print("Should play podcast...")
            self.player.play()
            self.playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            self.miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            
            self.setupElapsedTime(playbackRate: 1)
            
            return .success
        }
        
        commandCenter.pauseCommand.isEnabled = true
        
        commandCenter.pauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            print("Should pause podcast...")
            self.player.pause()
            self.playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            self.miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            self.setupElapsedTime(playbackRate: 0)
            
            return .success
        }
        
        commandCenter.togglePlayPauseCommand.isEnabled = true
        
        commandCenter.togglePlayPauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            
            self.handlePlayPause()
            
            return .success
        }
        
        commandCenter.nextTrackCommand.addTarget(self, action: #selector(handleNextTrack))
        
        commandCenter.previousTrackCommand.addTarget(self, action: #selector(handlePreviousTrack))
    }
    
    @objc fileprivate func handleNextTrack() {
        changeEpisode(forward: true)
    }
    
    @objc fileprivate func handlePreviousTrack() {
        changeEpisode(forward: false)
    }
    
    fileprivate func changeEpisode(forward: Bool) {
        
        guard !playlistEpisodes.isEmpty else { return }
        
        let currentEpisodeIndex = playlistEpisodes.index(of: episode)
        
        guard var index = currentEpisodeIndex else { return }
        
        if forward {
            if index == playlistEpisodes.count - 1 {
                index = 0
            } else {
                index = index + 1
            }
        } else {
            if index == 0 {
                index = playlistEpisodes.count - 1
            } else {
                index = index - 1
            }
        }
        
        let nextEpisode = playlistEpisodes[index]
        
        self.episode = nextEpisode
    }
    
    fileprivate func setupElapsedTime(playbackRate: Float) {
        
        let elapsedTime = CMTimeGetSeconds(player.currentTime())
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = playbackRate
    }
    
    fileprivate func setupAudioSessions() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let sessionErr {
            print("Failed to activate session: ", sessionErr)
        }
    }
    
    fileprivate func setupGestures() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMaximize)))
        
        miniPlayerView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan)))
        
        maximizedStackView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismissalPan)))
    }
    
    fileprivate func observePlayerCurrentTime() {
        let interval = CMTimeMake(1, 2)
        
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            
            self?.currentTimeLabel.text = time.toDisplayString()
            
            self?.durationLabel.text = self?.player.currentItem?.duration.toDisplayString()
            
            
            self?.updateCurrentTimeSlider()
        }
    }
    
    fileprivate func setupLockscreenCurrentTime() {
        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo

        guard let currentItem = player.currentItem else { return }
        let durationInSeconds = CMTimeGetSeconds(currentItem.duration)

//        let elapsedTime = CMTimeGetSeconds(player.currentTime())
//
//        nowPlayingInfo![MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime

        nowPlayingInfo![MPMediaItemPropertyPlaybackDuration] = durationInSeconds

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    fileprivate func updateCurrentTimeSlider() {
        
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(1, 1))
        
        let percentage = currentTimeSeconds / durationSeconds
        
        self.currentTimeSlider.value = Float(percentage)
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
    
    fileprivate func playEpisode() {
        print("Trying to play episode at url: ", episode.streamUrl)
        
        guard let url = URL(string: episode.streamUrl) else { return }
        let currentItem = AVPlayerItem(url: url)
        
        player.replaceCurrentItem(with: currentItem)
        player.play()
    }
    
    fileprivate func seekToCurrentTime(delta: Int64) {
        let fifteenSeconds = CMTimeMake(delta, 1)
        
        let seekTime = CMTimeAdd(player.currentTime(), fifteenSeconds)
        
        player.seek(to: seekTime)
    }
    
    fileprivate func handlePanEnded(_ gesture: UIPanGestureRecognizer, _ translation: CGPoint) {
        let velocity = gesture.velocity(in: self.superview)
        
        print("velocity ", velocity)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.transform = .identity
            
            if translation.y < -200 || velocity.y < -500 {
                
                UIApplication.mainTabBarController().maximizePlayerDetails()
                
            } else {
                self.miniPlayerView.alpha = 1
                self.maximizedStackView.alpha = 0
            }
            
        })
    }
    
    fileprivate func handlePanChanged(_ translation: CGPoint) {
        self.transform = CGAffineTransform(translationX: 0, y: translation.y)
        
        self.miniPlayerView.alpha = 1 + translation.y / 200
        self.maximizedStackView.alpha = -translation.y / 200
    }
    
    // MARK: - ACTIONS
    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        print("translation: ", translation)
        
        switch gesture.state {
        case .began:
            break
        case .changed:
            handlePanChanged(translation)
            
        case .ended:
            handlePanEnded(gesture, translation)
            
        default:
            break
        }
    }
    
    @objc func handleDismissalPan(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)

        switch gesture.state {
        case .changed:
            maximizedStackView.transform = CGAffineTransform(translationX: 0, y: translation.y)
            
        case .ended:
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.maximizedStackView.transform = .identity
                
                if translation.y > 50 {
                    
                    UIApplication.mainTabBarController().minimizePlayerDetails()
                }
            })
        default:
            break
        }
    }
    
    @objc func handlePlayPause() {
        
        if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            enlargeEpisodeImageView()
            self.setupElapsedTime(playbackRate: 1)
        } else {
            player.pause()
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            shrinkEpisodeImageView()
            self.setupElapsedTime(playbackRate: 0)
        }
    }
    
    @objc func handleTapMaximize() {
        
        UIApplication.mainTabBarController().maximizePlayerDetails()
        
    }
    
    @IBAction func handleDismiss(_ sender: Any) {
        
        UIApplication.mainTabBarController().minimizePlayerDetails()
        
    }
    
    @IBAction func handleCurrentTimeSliderChange(_ sender: Any) {
        let percentage = currentTimeSlider.value
        
        guard let duration = player.currentItem?.duration else { return }
        
        let durationInSeconds = CMTimeGetSeconds(duration)
        
        let seekTimeInSeconds = Double(percentage) * durationInSeconds
        
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, Int32(NSEC_PER_SEC))
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = seekTimeInSeconds
        
        player.seek(to: seekTime)
    }
    
    @IBAction func handleRewind(_ sender: Any) {
        seekToCurrentTime(delta: -15)
    }
    
    @IBAction func handleFastForward(_ sender: Any) {
        
        seekToCurrentTime(delta: 15)
    }
    
    @IBAction func handleVolumeChange(_ sender: Any) {
        player.volume = (sender as! UISlider).value
    }
    
}
