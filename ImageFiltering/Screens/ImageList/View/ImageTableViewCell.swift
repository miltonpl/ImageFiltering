//
//  ImageTableViewCell.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/2/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var itemImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var sourceLabel: UILabel!
    static let identifier = "ImageTableViewCell"
    var stringUrl:String?
    func setProterties( item: ImageInfo, title: String){
        self.itemImageView.layer.cornerRadius = itemImageView.frame.height/5
        self.itemImageView.layer.borderWidth = 2
        self.itemImageView.layer.borderColor = UIColor.black.cgColor
        self.itemImageView.layer.backgroundColor = UIColor.green.cgColor
        self.sourceLabel.text = item.site
        self.titleLabel.text = title
        
        guard let stringUrl = item.imageUrl, let url = URL(string: stringUrl) else { return }
        self.stringUrl = stringUrl
        self.itemImageView.downloadImage(with: url)
    }
    @IBAction func linkToWeb(_ sender: UIButton) {
        guard let url = URL(string: stringUrl ?? "") else {return}
               UIApplication.shared.open(url)
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "ImageTableViewCell", bundle: nil)
    }
}

extension UIImageView {
    
    func downloadImage(with url: URL){
        DispatchQueue.global().async {
            do {
                //convert data to UIImage
                let data  = try Data(contentsOf: url)
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    self.image = image
                }
            }
            catch {
                print(error)
            }
        }
    }
}
