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


struct Constants {
    static let Search_Endpoint = "search"
    static let Query = "query="
    static let url1Str = "http://www.splashbase.co/api/v1/images/search?query="
    static let url2Key = "key=18552487-1f1f788770c0bd9185181a8ff"
    static let url2Base = "https://pixabay.com/api/?"
    
    static let url3Str = "https://api.pexels.com/v1/search?query="
    static let headers3 = [
        "Authorization": "563492ad6f91700001000001d7f7e19ada2d4640964a4f90731831bf"
    ]
    
}

