//
//  Constants.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/16/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import UIKit

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
