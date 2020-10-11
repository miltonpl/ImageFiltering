//
//  MyCollectionViewCell.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/10/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import UIKit

class MyCollectionViewCell: UICollectionViewCell {
  
    static let identifier = "MyCollectionViewCell"
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    static func nib() -> UINib {
        return UINib(nibName: "MyCollectionViewCell", bundle: nil)
    }
    
    func configure(photoInfo: PhotoInfo) {
        self.titleLabel.text = photoInfo.title
        self.itemImageView.image = photoInfo.image
        self.itemImageView.layer.borderWidth = 2
        self.itemImageView.layer.borderColor = UIColor.black.cgColor
        self.itemImageView.contentMode = .scaleAspectFill

    }
}
