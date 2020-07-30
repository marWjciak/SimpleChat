//
//  Image.swift
//  SimpleChat
//
//  Created by Marcin Wójciak on 23/05/2020.
//  Copyright © 2020 Marcin Wójciak. All rights reserved.
//

import MessageKit
import UIKit

struct Image: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}
