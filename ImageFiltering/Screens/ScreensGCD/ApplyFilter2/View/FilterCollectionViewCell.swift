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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    static func nib() -> UINib {
        return UINib(nibName: "FilterCollectionViewCell", bundle: nil)
    }
    
    func configure(imageUrl: String, filter: FilterType ) {
        activityIndicator.startAnimating()
        self.itemImageView.layer.borderWidth = 2
        self.itemImageView.layer.borderColor = UIColor.black.cgColor
        self.titleLabel.textColor = .darkGray
        self.titleLabel.text = "\(filter)"
        if filter != .none {
            DispatchQueue.global().async {
                ServiceManager.manager.applyFilter(imageUrl: imageUrl, filter: filter) { image in
                    guard let image = image else { print("Ops no Image"); return }
                    DispatchQueue.main.async {
                        self.itemImageView.image = image
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                        
                        print("image success")
                    }
                }
            }
            print("In Collection Cell")
        } else {
            guard let url = URL(string: imageUrl) else { return }
            
            itemImageView.downloadImage(with: url)
        }
    }
}
