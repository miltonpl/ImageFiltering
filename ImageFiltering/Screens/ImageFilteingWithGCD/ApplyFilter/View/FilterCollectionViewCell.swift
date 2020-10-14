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
    @IBOutlet weak var itemImageView: UIImageView! {
        didSet {
            self.itemImageView.layer.borderWidth = 2
            self.itemImageView.layer.borderColor = UIColor.black.cgColor
            self.itemImageView.contentMode = .scaleAspectFill
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    
    let indicator = UIActivityIndicatorView(style: .medium)

    static func nib() -> UINib {
        return UINib(nibName: "FilterCollectionViewCell", bundle: nil)
    }
    
    func configure(image: UIImage, filter: FilterType ) {
        self.indicator.frame = self.itemImageView.bounds
        self.indicator.color = .black
        self.indicator.startAnimating()
        self.itemImageView.addSubview(indicator)
        self.titleLabel.text = " Filtering ..."
        self.titleLabel.textColor = .darkGray
        
        if filter != .none {
            self.itemImageView.applyFilterToImage(image, filter)
            self.indicator.stopAnimating()
            self.indicator.removeFromSuperview()
            self.titleLabel.text = "\(filter)"
            
        } else {
            self.itemImageView.image = image
            
            self.titleLabel.text = "\(filter)"
            self.indicator.stopAnimating()
            self.indicator.removeFromSuperview()
        }
    }
}
