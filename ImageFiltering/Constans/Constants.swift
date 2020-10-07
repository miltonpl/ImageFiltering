//
//  URLs.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/2/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import Foundation
enum Source: String {
    case splashbase = "http://www.splashbase.co/api/v1/images/search?query="
    case pixabay = "https://pixabay.com/api/?key=18552487-1f1f788770c0bd9185181a8ff&image_type=photo&q="
    case pexels = "https://api.pexels.com/v1/search?query="
}

enum Constants {
    static let SearchEndpoint = "search"
    static let Query = "query="
    static let url1Str = "http://www.splashbase.co/api/v1/images/search?query="
    static let url2Key = "key=18552487-1f1f788770c0bd9185181a8ff"
    static let url2Base = "https://pixabay.com/api/?"
    static let url3Str = "https://api.pexels.com/v1/search?query="
    static let headers3 = [
        "Authorization": "563492ad6f91700001000001d7f7e19ada2d4640964a4f90731831bf"
    ]
}

struct ProviderInfo {
    var name: ProviderType
    var isOn: Bool = true
}
enum ProviderType: String {
    case splash = "Splash"
    case pexels = "Pexels"
    case pixaBay = "Pixa Bay"
}

enum Splash {
    
    static let name = "Splash"
    static let url = "http://www.splashbase.co/api/v1/images/search?"
    static let parameters = ["query": ""]
}

enum Pexels {
    
    static let name = "Pexels"
    static let url = "https://api.pexels.com/v1/search?"
    static let parameters = ["query": ""]
    static let headers = ["Authorization": "563492ad6f91700001000001d7f7e19ada2d4640964a4f90731831bf"]
}

enum PixaBay {
    
    static let name = "Pixa Bay"
    static let url = "https://pixabay.com/api/?"
    static let parameters = ["key": "18552487-1f1f788770c0bd9185181a8ff", "q": "", "image_type": "photo"]
}
