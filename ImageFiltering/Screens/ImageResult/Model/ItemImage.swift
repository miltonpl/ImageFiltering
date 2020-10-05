//
//  ImageData.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/3/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import UIKit

enum Section: String {
    case splashbase = "Splashbase"
    case pixabay = "Pixbay"
    case pexels = "Pexels"
    
}

struct SectionState {
    var state: Bool
    var section: Section
}
