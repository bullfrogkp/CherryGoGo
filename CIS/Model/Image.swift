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
    
    init(name: String, items: [Item], customers: [Customer], imageFile: Data) {
        self.name = name
        self.items = items
        self.customers = customers
        self.imageFile = imageFile
    }
    
    convenience init(name: String) {
        self.init(name: name, items: [], customers: [], imageFile: UIImage(named: name)!.pngData()!)
    }
    
    convenience init(imageFile: Data) {
        self.init(name: "", items: [], customers: [], imageFile: imageFile)
    }
    
    convenience init(name: String, imageFile: Data, customers: [Customer]) {
        self.init(name: name, items: [], customers: customers, imageFile: imageFile)
    }
    
    convenience init() {
        self.init(name: "test", items: [], customers: [], imageFile: UIImage(named: "test")!.pngData()!)
    }
}
