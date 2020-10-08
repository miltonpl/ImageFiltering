//
//  URLResponse.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/2/20.
//  Copyright © 2020 Milton. All rights reserved.
//
import UIKit

struct PhotoSection {
    var name: ProviderType
    var photos: [PhotoProtocol]?
}

protocol PhotoProtocol {
    var name: String? { get }
    var imageUrl: String? { get }
    
    init(dict: [String: Any], name: String)
}

struct SplashPhotoInfo: PhotoProtocol {
    var name: String?
    var imageUrl: String?
    
    init(dict: [String: Any], name: String) {
        self.imageUrl = dict["url"] as? String
        self.name = name
    }
}

struct PexelsPhotoInfo: PhotoProtocol {
    var imageUrl: String?
    var name: String?
    
    init(dict: [String: Any], name: String) {
        if let src = dict["src"] as? [String: Any] {
            self.imageUrl = src["medium"] as? String
            self.name = name

        }
    }
}

struct PixabayPhotoInfo: PhotoProtocol {
    var imageUrl: String?
    var name: String?
    
    init(dict: [String: Any], name: String) {
        self.imageUrl = dict["webformatURL"] as? String
        self.name = name

    }
}
