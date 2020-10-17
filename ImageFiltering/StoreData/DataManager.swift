//
//  ImportData.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/12/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import UIKit

enum DataError: Error {
    case pathNotFound
    case dataNotFound
    case jsonSerialization
}

class DataManager {
    static let shared = DataManager()
    private init() {}
    
    func writeDataInJsonFormat(fileName: String, photos: [PhotoModel], completion: (DataError?) -> Void) {
        guard let documetDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            completion(.pathNotFound)
            return }
        let fileUrl = documetDirectoryUrl.appendingPathComponent(fileName)
        var topLevel: [Any] = []
        photos.forEach { photo in
            var photoDict: [String: Any] = [:]
            photoDict["providerName"] = photo.providerName
            photoDict["filterType"] = photo.filterType.rawValue
            photoDict["url"] = photo.url
            topLevel.append(photoDict)
        }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: topLevel, options: .prettyPrinted)
            try jsonData.write(to: fileUrl)
            
        } catch {
            print(error)
            completion(.jsonSerialization)
        }
    }
    
    func jsonReadData(fileName: String, completion: ([PhotoModel]?, DataError?) -> Void) {
        
        var photos: [PhotoModel]? = []
        guard let documetDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { completion(nil, .pathNotFound); return }
        let fileUrl = documetDirectoryUrl.appendingPathComponent(fileName)
        
        do {
            let jsonData = try Data(contentsOf: fileUrl)
            let reponseObj = try JSONDecoder().decode([PhotoModelTemp].self, from: jsonData)
            reponseObj.forEach { photoObj in
                let filterType = setupFilterType(type: photoObj.filterType)
                photos?.append(PhotoModel(url: photoObj.url, filterType: filterType, providerName: photoObj.providerName))
            }
            completion(photos, nil)//return
        } catch {
            print(error)
            completion(nil, .dataNotFound)//return
        }
    }
    func setupFilterType(type: String) -> FilterType {
        
        switch type {
        case "CIPhotoEffectChrome":
            return FilterType.chrome
            
        case "CIPhotoEffectFade":
            return FilterType.fade
            
        case "CIPhotoEffectInstant":
            return FilterType.instant
            
        case "CIPhotoEffectMono":
            return FilterType.mono
            
        case "CIPhotoEffectNoir":
            return FilterType.noir
            
        case "CIPhotoEffectProcess":
            return FilterType.process
            
        case "CIPhotoEffectTonal":
            return FilterType.tonal
            
        case "CIPhotoEffectTransfer":
            return FilterType.transfer
            
        case "None":
            return FilterType.none
            
        default:
            return FilterType.none
        }
    }
}
