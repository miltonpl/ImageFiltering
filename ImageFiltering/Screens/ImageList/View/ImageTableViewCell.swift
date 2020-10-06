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
    
    private var stringUrl: String?
    
    func setProterties( urlStr: String?) {
        self.itemImageView.layer.cornerRadius = itemImageView.frame.height / 5
        self.itemImageView.layer.borderWidth = 2
        self.itemImageView.layer.borderColor = UIColor.black.cgColor
//        self.sourceLabel.text = item.source
//        self.titleLabel.text = item.title
//        self.stringUrl = item.site
//        self.itemImageView.image = item.image
        guard let urlStr = urlStr, let url = URL(string: urlStr) else { return }
        itemImageView.downloadImage(with: url)
    }
    @IBAction private func linkToWeb(_ sender: UIButton) {
        guard let url = URL(string: stringUrl ?? "") else { return }
               UIApplication.shared.open(url)
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "ImageTableViewCell", bundle: nil)
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
