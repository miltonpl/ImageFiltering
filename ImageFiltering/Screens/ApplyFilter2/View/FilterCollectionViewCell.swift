//
//  FilterCollectionViewCell.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/8/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import UIKit

class FilterCollectionViewCell: UICollectionViewCell {
    static let identifier = "FilterCollectionViewCell"
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
   
    static func nib() -> UINib {
        return UINib(nibName: "FilterCollectionViewCell", bundle: nil)
    }
    func configure(image: UIImage, title: String) {
        self.itemImageView.image = image
        self.titleLabel.text = title
        print("In Collection Cell")
    }

}
