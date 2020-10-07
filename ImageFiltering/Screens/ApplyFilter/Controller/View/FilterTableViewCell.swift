//
//  FilterTableViewCell.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/7/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import UIKit

class FilterTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var filterNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func set(name: String) {
        self.filterNameLabel.text = name
    }
    
}
