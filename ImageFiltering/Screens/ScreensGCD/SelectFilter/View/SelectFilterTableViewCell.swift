//
//  SelectFilterTableViewCell.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/9/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import UIKit

class SelectFilterTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    
    func configure(filter: FilterType) {
        nameLabel.text = "\(filter)"
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none

        // Configure the view for the selected state
    }
}
