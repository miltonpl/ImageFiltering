//
//  PhotoSearchTableViewCell.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/11/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import UIKit
//Plain Object of UIView
class PhotoSearchTableViewCell: UITableViewCell {
    
    static let identifier = "PhotoSearchTableViewCell"
    let indicator = UIActivityIndicatorView()
    
    @IBOutlet weak var itemImageView: UIImageView! {
        didSet {
            self.itemImageView.layer.borderWidth = 3
            self.itemImageView.layer.borderColor = UIColor.black.cgColor
            self.itemImageView.contentMode = .scaleAspectFill
        }
    }
    @IBOutlet weak var filterLabel: UILabel!
    
    static func nib() -> UINib {
        return UINib(nibName: "PhotoSearchTableViewCell", bundle: nil)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none
    }
    
    func setProterties(photoDetails: PhotoProtocol) {
        
        if accessoryView == nil {
            indicator.frame = self.itemImageView.bounds
            indicator.color = .black
            self.itemImageView.addSubview(indicator)
        }
        
        switch photoDetails.state {
        case .new, .downloaded:
            indicator.startAnimating()
            filterLabel.text = " Filtering ..."
            
        case .filtered:
            indicator.stopAnimating()
            indicator.removeFromSuperview()
            filterLabel.text = " \(photoDetails.filter)"
            
        case .failed:
            indicator.stopAnimating()
            indicator.removeFromSuperview()
            filterLabel.text = " Fail to load"
        }
        
        self.itemImageView.image = photoDetails.image
       
    }
}
