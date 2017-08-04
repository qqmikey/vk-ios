//
//  Extensions.swift
//  vkauth
//
//  Created by Mikhail Rymarev on 03.08.17.
//  Copyright © 2017 Mikhail Rymarev. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

extension UIImageView {
    func setImage(img: VKImage?, callback: ((UIImage) -> ())?=nil) {
        if let avatar = img?.image {
            self.image = avatar
        } else {
            if let url = img?.src {
                let resource = ImageResource(downloadURL: url, cacheKey: url.lastPathComponent)
                self.kf.setImage(with: resource, completionHandler: {
                    (image, error, cacheType, imageUrl) in
                    if let cb = callback, let img = image {
                        cb(img)
                    }
                })
            }
        }
    }
}
