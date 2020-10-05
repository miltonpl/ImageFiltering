//
//  PixabayModel.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/4/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import Foundation

protocol ResponseProtocol {
    
}
class PixaBay: ResponseProtocol, Decodable {
    var photos: [HitsInfo]?
    enum CodingKeys: String, CodingKey {
        case photos = "hits"
    }
}
class HitsInfo: Decodable {
    var pageUrl: String?
    var webformUrl: String?
    var previewUrl: String?
    var tags: String?
    var largeImageUrl: String?
    var user: String?
    var userUrl: String?
    enum CodingKeys: String, CodingKey {
       case pageUrl
       case webformUrl = "webformURL"
       case previewUrl = "previewURL"
       case tags
       case largeImageUrl = "largeImageURL"
       case user
       case userUrl
    }
}
