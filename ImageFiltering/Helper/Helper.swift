//
//  Helper.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/12/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import UIKit

struct Helper {
    lazy var providersList: [Provider] = {
        var list: [Provider] = [
            Provider(name: Splash.name, url: Splash.url, parameter: Splash.parameters, isOn: true),
            Provider(name: PixaBay.name, url: PixaBay.url, parameter: PixaBay.parameters, isOn: true),
            Provider(name: Pexels.name, url: Pexels.url, parameter: Pexels.parameters, header: Pexels.headers, isOn: true)
        ]
        return list
    }()
    
    lazy var providersInfo: [ProviderInfo] = {
        var providers: [ProviderInfo] = [
            ProviderInfo(name: .splash, isOn: true),
            ProviderInfo(name: .pixaBay, isOn: true),
            ProviderInfo(name: .pexels, isOn: true)
        ]
        return providers
    }()
    
    lazy var context: CIContext = {
        var context = CIContext(options: nil)
        return context
    }()
    
    lazy var filterTypes: [FilterType] = {
        var filterList: [FilterType] = [.none, .chrome, .fade, .instant, .noir, .tonal, .transfer, .process]
        return filterList
    }()
    
}
