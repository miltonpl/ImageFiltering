//
//  URLs.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/2/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import UIKit
enum Source: String {
    case splashbase = "http://www.splashbase.co/api/v1/images/search?query="
    case pixabay = "https://pixabay.com/api/?key=18552487-1f1f788770c0bd9185181a8ff&image_type=photo&q="
    case pexels = "https://api.pexels.com/v1/search?query="
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
    
    static let name = ProviderType.splash
    static let url = "http://www.splashbase.co/api/v1/images/search?"
    static let parameters = ["query": ""]
}

enum Pexels {
    
    static let name = ProviderType.pexels
    static let url = "https://api.pexels.com/v1/search?"
    static let parameters = ["query": ""]
    static let headers = ["Authorization": "563492ad6f91700001000001d7f7e19ada2d4640964a4f90731831bf"]
}

enum PixaBay {
    
    static let name = ProviderType.pixaBay
    static let url = "https://pixabay.com/api/?"
    static let parameters = ["key": "18552487-1f1f788770c0bd9185181a8ff", "q": "", "image_type": "photo"]
}

enum Constants {
    static let ciContext = CIContext()
    static let failedImage = UIImage(named: "Failed")!
    static let placeHolderImage = UIImage(named: "Placeholder")!
    static let filterTypes: [FilterType] = [.none, .chrome, .fade, .instant, .mono, .noir, .process, .tonal, .transfer]
    static let providers: [Provider] = [
        Provider(name: Splash.name, url: Splash.url, parameter: Splash.parameters, isOn: true),
        Provider(name: PixaBay.name, url: PixaBay.url, parameter: PixaBay.parameters, isOn: true),
        Provider(name: Pexels.name, url: Pexels.url, parameter: Pexels.parameters, header: Pexels.headers, isOn: true)
        ]
    static let providerInfo: [ProviderInfo] = [
        ProviderInfo(name: .splash, isOn: true),
        ProviderInfo(name: .pixaBay, isOn: true),
        ProviderInfo(name: .pexels, isOn: true)
        ]
}
