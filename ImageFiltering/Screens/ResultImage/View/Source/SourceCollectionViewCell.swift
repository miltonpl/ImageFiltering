//
//  SourceCollectionViewCell.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/3/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import UIKit

class SourceCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var onoffSwitch: UISwitch!
    var section:Section?
    @IBAction func changedSwitch(_ sender: UISwitch){
        guard let section = self.section else {return }

        if sender.isOn {
            print( section.rawValue + ": is on")
            postNotification(section: SectionState(state: true, section: section ))

        }
        else {
            print( section.rawValue + ": is off")
            postNotification(section: SectionState(state: false, section: section ))
            
        }
        
    }
    func configure(section: Section){
        
        self.nameLabel.text = section.rawValue
        self.section = section
    }
    func postNotification(section: SectionState){

        let data:[String: SectionState] = ["data": section]
        NotificationCenter.default.post(name: .myNotification, object: nil, userInfo: data)
        
    }
}

extension Notification.Name{
    static let myNotification = Notification.Name("AddRemove")
}
