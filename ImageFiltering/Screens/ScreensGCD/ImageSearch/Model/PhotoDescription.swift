//
//  URLResponse.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/2/20.
//  Copyright © 2020 Milton. All rights reserved.
//
/*
 enum PhotoRecordState {
     case new, downloaded, filtered, failed
 }

 class PhotoRecord {
     let name: String
     let url: URL
     var state = PhotoRecordState.new
     var image = UIImage(named: "Placeholder")
     init (name: String, url: URL) {
         self.name = name
         self.url = url
     }
 }
 */
enum PhotoRecordState {
    case new, downloaded, filtered, failed
}

import UIKit

struct PhotoSection {
    var name: ProviderType
    var photos: [PhotoProtocol]?
}

protocol PhotoProtocol {
    var name: ProviderType { get }
    var imageUrl: String? { get }
    var state: PhotoRecordState { get set }
    var image: UIImage? { get set }
    var filter: FilterType { get set }
    
    init(dict: [String: Any], name: ProviderType)
}

struct SplashPhotoInfo: PhotoProtocol {
    
    var name: ProviderType
    var imageUrl: String?
    var state = PhotoRecordState.new
    var filter = FilterType.none
    var image: UIImage? = UIImage(named: "Placeholder")
    
    init(dict: [String: Any], name: ProviderType) {
        self.imageUrl = dict["url"] as? String
        self.name = name
    }
}

struct PexelsPhotoInfo: PhotoProtocol {
    var imageUrl: String?
    var name: ProviderType
    var state = PhotoRecordState.new
    var image: UIImage? = UIImage(named: "Placeholder")
    var filter = FilterType.none
    
    init(dict: [String: Any], name: ProviderType) {
        if let src = dict["src"] as? [String: Any] {
            self.imageUrl = src["medium"] as? String
        }
        self.name = name
    }
}

struct PixabayPhotoInfo: PhotoProtocol {
    var imageUrl: String?
    var name: ProviderType
    var state = PhotoRecordState.new
    var filter = FilterType.none
    var image: UIImage? = UIImage(named: "Placeholder")
    init(dict: [String: Any], name: ProviderType) {
        self.imageUrl = dict["webformatURL"] as? String
        self.name = name

    }
}
