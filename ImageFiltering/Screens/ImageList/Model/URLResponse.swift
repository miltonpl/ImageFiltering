//
//  URLResponse.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/2/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import Foundation



class APIResponse: Decodable {
    
    var image: [ImageInfo]?
    enum CodingKeys: String, CodingKey {
        case image = "images"
    }
}

class ImageInfo: Decodable {
    var idImage: Int?
    var imageUrl: String?
    var lardgeImageUrl: String?
    var sourceId: Int?
    var copyRight: String?
    var site: String?
    
    enum CodingKeys: String, CodingKey {
        
        case idImage = "id"
        case imageUrl = "url"
        case lardgeImageUrl = "large_url"
        case sourceId = "source_id"
        case copyRight = "copyright"
        case site
    }

}

  
