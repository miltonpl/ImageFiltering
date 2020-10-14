//
//  Provider.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/5/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import Foundation
struct Provider {
    var name: ProviderType
    var url: String
    var parameter: [String: String]?
    var header: [String: String]?
    var isOn: Bool
}
