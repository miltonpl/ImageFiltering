//
//  SplashbaseModel.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/4/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import Foundation

class Splashbase: ResponseProtocol, Decodable {
    
    var image: [ImageInfo]?
    enum CodingKeys: String, CodingKey {
        case image = "images"
    }
}

class ImageInfo: Decodable {
    var imageUrl: String?
    var lardgeImageUrl: String?
    var site: String?
    
    enum CodingKeys: String, CodingKey {
        
        case imageUrl = "url"
        case lardgeImageUrl = "large_url"
        case site
    }

}

  
