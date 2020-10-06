//
//  ProviderTableViewCell.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/6/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import UIKit

class ProviderTableViewCell: UITableViewCell {
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var providerSwitch: UISwitch!
    
    @IBAction private func stateSwitch(_ sender: UISwitch ) {
        
        if sender.isOn {
            print("On")
        } else {
            print("OFF")
        }
    }
    func configure(_ provider: String ) {
        nameLabel.text = provider
    }
}
