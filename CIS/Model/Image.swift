//
//  Image.swift
//  CIS
//
//  Created by Kevin Pan on 2019-08-21.
//  Copyright © 2019 Kevin Pan. All rights reserved.
//

import Foundation
import UIKit

class Image {
    var imageFile: Data
    
    var name: String?
    var items: [Item]?
    var customers: [Customer]?
    var newImage: Image?
    var imageMO: ImageMO?
    
    init(imageFile: Data) {
        self.imageFile = imageFile
    }
    
    convenience init(name: String) {
        let imgFile = UIImage(named: name)!.pngData()!
        self.init(imageFile: imgFile)
    }
}
