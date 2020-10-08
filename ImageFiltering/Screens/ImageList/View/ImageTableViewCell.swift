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
    
    func setProterties( urlStr: String?, providerName: String) {
        self.itemImageView.layer.borderWidth = 3
        self.itemImageView.layer.borderColor = UIColor.black.cgColor
        guard let urlStr = urlStr, let url = URL(string: urlStr) else { return }
        itemImageView.downloadImage(with: url)
    }
}

extension UIImageView {
    
    func downloadImage(with url: URL) {
        DispatchQueue.global().async {
            do {
                //convert data to UIImage
                let data = try Data(contentsOf: url)
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    self.image = image
                }
            } catch {
                print(error)
            }
        }
    }
}
