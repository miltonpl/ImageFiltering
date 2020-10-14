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
        return UINib(nibName: "MyCollectionViewCell", bundle: nil)
    }
    
    func configure(_ photoModel: PhotoModel) {
        
        indicator.frame = itemImageView.bounds
        itemImageView.addSubview(indicator)
        indicator.startAnimating()
        indicator.color = .darkGray
        self.titleLabel.text = photoModel.providerName
        
        if let strUrl = photoModel.url, let url = URL(string: strUrl ) {
            print(photoModel.filterType)
            if photoModel.filterType == .none {
                itemImageView.downloadImage(with: url)
                print(url)
                indicator.stopAnimating()
                indicator.removeFromSuperview()
            } else {
                itemImageView.downloadAndApplyFilterToImage(url, photoModel.filterType)
                print(url)
                indicator.stopAnimating()
                indicator.removeFromSuperview()
            }
        } else {
            itemImageView.image = UIImage(named: "Failed")!
            indicator.stopAnimating()
            indicator.removeFromSuperview()
        }
    }
}
