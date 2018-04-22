//
//  UIApplication.swift
//  Podcasts
//
//  Created by Anton Novoselov on 22/04/2018.
//  Copyright © 2018 Anton Novoselov. All rights reserved.
//

import UIKit

extension UIApplication {
    static func mainTabBarController() -> MainTabBarController {
        return shared.keyWindow?.rootViewController as! MainTabBarController
    }
}

