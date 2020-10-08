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
    var originalImage: UIImage?
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    static func nib() -> UINib {
        return UINib(nibName: "FilterCollectionViewCell", bundle: nil)
    }
    func configure(image: UIImage, filter: FilterType) {
        activityIndicator.startAnimating()
        self.itemImageView.layer.borderWidth = 2
        self.itemImageView.layer.borderColor = UIColor.black.cgColor
        self.itemImageView.image = image
        self.titleLabel.textColor = .darkGray
        self.titleLabel.text = "\(filter)"
//        self.originalImage = image
//        self.setFilter(filter: filter)
        self.activityIndicator.isHidden = true

        print("In Collection Cell")
    }
    
}
//extension FilterCollectionViewCell {
//    func setFilter(filter: FilterType) {
//        DispatchQueue.global().async {
//            let image = self.originalImage?.applyFilter(filter: filter)
//            DispatchQueue.main.sync {
//                self.itemImageView.image = image
//                self.activityIndicator.isHidden = true
//                print("Done in FilterCollectionViewCell", filter.rawValue)
//
//            }
//        }
//    }
//}
