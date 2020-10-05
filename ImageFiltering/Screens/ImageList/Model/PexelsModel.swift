//
//  PexelsModel.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/4/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import Foundation

class Pexels: ResponseProtocol, Decodable {
    var photos: [PhotoInfo]?
}
class PhotoInfo: Decodable {
  
    var urlPexel: String?
    var protographer: String?
    var protographerUrl: String?
    var protographerId: Int?
    var sourceImage: SourceImage?
    enum CodingKeys: String, CodingKey {
     
        case urlPexel = "url"
        case protographer
        case protographerUrl = "protographer_url"
        case protographerId = "protographer_id"
        case sourceImage = "src"
    }
    
}

class SourceImage: Decodable {
    var original: String?
    var large2x: String?
    var large: String?
    var medimum: String?
    var small: String?
    var portrail: String?
    var landscape: String?
    var tiny: String?
}
