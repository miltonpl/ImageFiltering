//
//  URLResponse.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/2/20.
//  Copyright © 2020 Milton. All rights reserved.
//
import UIKit

struct PhotoDescription {
    var image: UIImage?
    var author: String?
    var site: String?
    var title: String?
    var source: String?
}

//struct Sections {
//    var title: String?
//    var dataSource: [PhotoProtocol]?
//}

protocol PhotoProtocol {
    var imageUrl: String? { get }
    
    init(dict: [String: Any])
}

struct SplashPhotoInfo: PhotoProtocol {
    var imageUrl: String?
    
    init(dict: [String: Any]) {
        self.imageUrl = dict["url"] as? String
    }
}

struct PexelsPhotoInfo: PhotoProtocol {
    var imageUrl: String?
    
    init(dict: [String: Any]) {
        if let src = dict["src"] as? [String: Any] {
            self.imageUrl = src["medium"] as? String
        }
    }
}

struct PixabayPhotoInfo: PhotoProtocol {
    var imageUrl: String?
    
    init(dict: [String: Any]) {
        self.imageUrl = dict["webformatURL"] as? String
    }
}
