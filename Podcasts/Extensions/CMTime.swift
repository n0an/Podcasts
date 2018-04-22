//
//  CMTime.swift
//  Podcasts
//
//  Created by Anton Novoselov on 22/04/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import AVKit

extension CMTime {
    
    func toDisplayString() -> String {
        
        if CMTimeGetSeconds(self).isNaN {
            return "--:--"
        }
        
        let totalSeconds = Int(CMTimeGetSeconds(self))
        
        let seconds = totalSeconds % 60
        let minutes = totalSeconds / 60
        
        let timeFormatString = String(format: "%02d:%02d", minutes, seconds)
        
        return timeFormatString
    }
    
}
