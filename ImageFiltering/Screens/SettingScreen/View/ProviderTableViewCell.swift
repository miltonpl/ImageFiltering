//
//  ProviderTableViewCell.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/6/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import UIKit
protocol ProviderTableViewCellDelegate: AnyObject {
    func canChangeStatus() -> Bool
    func didChangeStatus(provider: ProviderInfo)
    func notifyUser()
}

class ProviderTableViewCell: UITableViewCell {
    static let identifier = "ProviderTableViewCell"
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var providerSwitch: UISwitch!
    
    weak var delegate: ProviderTableViewCellDelegate?
    var provider: ProviderInfo?
    
    static func nib() -> UINib {
        return UINib(nibName: "ProviderTableViewCell", bundle: nil)
    }
    
    func configure(_ provider: ProviderInfo) {
        self.nameLabel.text = provider.name.rawValue
        self.providerSwitch.isOn = provider.isOn
        self.provider = provider
    }
    
    @IBAction private func stateSwitch(_ sender: UISwitch ) {
        guard var provider = self.provider else { return }
        provider.isOn.toggle()
        if !provider.isOn {
            if delegate?.canChangeStatus() ?? false {
                delegate?.didChangeStatus(provider: provider)
                
            } else {
                sender.isOn = true
                provider.isOn.toggle()
                delegate?.notifyUser()
            }
            
        } else {
            delegate?.didChangeStatus(provider: provider)
        }
        self.provider?.isOn = provider.isOn
    }
}
