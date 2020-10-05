//
//  ItemTableViewCell.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/3/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import UIKit

class ItemTableViewCell:UITableViewCell {
    
    @IBOutlet private weak var itemImageView: UIImageView!
    
    static let identifier = "ItemTableViewCell"
    
    func configure(image: PhotoDescription){
//        self.itemImageView.layer.cornerRadius = itemImageView.frame.height/5
        self.itemImageView.layer.borderWidth = 2
        self.itemImageView.layer.borderColor = UIColor.black.cgColor
        self.itemImageView.image = image.image
    }
    
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
}


