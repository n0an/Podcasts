//
//  EpisodeCell.swift
//  Podcasts
//
//  Created by Anton Novoselov on 21/04/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import UIKit

class EpisodeCell: UITableViewCell {
    
    // MARK: - OUTLETS
    @IBOutlet weak var episodeImageView: UIImageView!
    @IBOutlet weak var pubDateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.numberOfLines = 2
        }
    }
    
    @IBOutlet weak var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.numberOfLines = 2
        }
    }
    
    @IBOutlet weak var progressLabel: UILabel!

    // MARK: - PROPERTIES
    var episode: Episode! {
        didSet {
            titleLabel.text = episode.title
            descriptionLabel.text = episode.description
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            pubDateLabel.text = dateFormatter.string(from: episode.pubDate)
            
            let url = URL(string: episode.imageUrl?.toSecureHTTPS() ?? "")
            episodeImageView.sd_setImage(with: url)
        }
    }
    
}
