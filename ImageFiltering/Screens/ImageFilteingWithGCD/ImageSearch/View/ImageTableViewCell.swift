//
//  ImageTableViewCell.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/2/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {
    
    static let identifier = "ImageTableViewCell"
    
    @IBOutlet private weak var itemImageView: UIImageView!
    
    static func nib() -> UINib {
        return UINib(nibName: "ImageTableViewCell", bundle: nil)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none
    }
    
    func setProterties( urlStr: String?, providerName: String, _ filter: FilterType? ) {
        self.itemImageView.layer.borderWidth = 3
        self.itemImageView.layer.borderColor = UIColor.black.cgColor
        self.itemImageView.contentMode = .scaleAspectFill
        guard let urlStr = urlStr, let url = URL(string: urlStr) else { return }
        
        if let filter = filter {
            DispatchQueue.global().async {
                ServiceManager.manager.applyFilter(imageUrl: urlStr, filter: filter) { image in
                    guard let image = image else { print("Unable to download/filter the image"); return }
                    DispatchQueue.main.async {
                        self.itemImageView.image = image
                    }
                }
            }
            
        } else {
            
            itemImageView.downloadImage(with: url)
        }
    }
}
