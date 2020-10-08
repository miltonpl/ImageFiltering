//
//  FilterTableViewCell.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/7/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import UIKit

protocol FilterTableViewCellDelegate: AnyObject {
    func setFilter(filter: FilterType )
}

class FilterTableViewCell: UITableViewCell {
    
    weak var delegate: FilterTableViewCellDelegate?

    @IBOutlet weak var selectedButton: UIButton!
    var filter: FilterType?
    
    func configure(name: String, filter: FilterType) {
        self.selectedButton.setTitle(name, for: selectedButton.state)
        self.filter = filter
    }
    
    @IBAction func selectedEffecs(_ sender: UIButton) {
        guard let filter = filter else { return }
        delegate?.setFilter(filter: filter)
    }
    
}
