//
//  PhotoInfo.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/10/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import UIKit

struct PhotoModel {
    var url: String?
    var filterType: FilterType = .none
    var providerName: String = "NONE"
}
struct PhotoModelTemp: Decodable {
    var url: String?
    var filterType: String
    var providerName: String
}
