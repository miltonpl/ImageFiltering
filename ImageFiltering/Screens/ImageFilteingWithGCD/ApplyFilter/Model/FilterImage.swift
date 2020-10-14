//
//  FilterImage.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/8/20.
//  Copyright © 2020 Milton. All rights reserved.
//
enum FilterType: String {
    case chrome = "CIPhotoEffectChrome"
    case fade = "CIPhotoEffectFade"
    case instant = "CIPhotoEffectInstant"
    case mono = "CIPhotoEffectMono"
    case noir = "CIPhotoEffectNoir"
    case process = "CIPhotoEffectProcess"
    case tonal = "CIPhotoEffectTonal"
    case transfer =  "CIPhotoEffectTransfer"
    case none = "None"
}
