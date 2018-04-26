//
//  Notification.swift
//  Podcasts
//
//  Created by Anton Novoselov on 26/04/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import Foundation

extension Notification.Name {
    
    static let downloadProgress = Notification.Name("downloadProgress")
    static let downloadComplete = NSNotification.Name("downloadComplete")
}
