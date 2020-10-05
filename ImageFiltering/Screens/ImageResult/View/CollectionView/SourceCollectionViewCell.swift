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
    var section: Section?
    var activeSections: Int?
    @IBAction func changedSwitch(_ sender: UISwitch){
        guard let section = self.section else {return }
        if let active = activeSections, active <= 1 {
            onoffSwitch.setOn(true, animated: true)
        }

        if sender.isOn {
            postNotification(section: SectionState(state: true, section: section ))
        }
        else {
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
extension SourceCollectionViewCell {
    
    func observerActiveSectionNotification() {
           NotificationCenter.default.addObserver(self, selector: #selector(getNotification), name: .myNotificationCount, object: nil)
       }
    //update section removed/add
   @objc func getNotification(_ notification: Notification) {
       guard let count = notification.userInfo?["items"] as? Int else {return }
        activeSections = count
        print("activeSection:", activeSections!)
   }
}

extension Notification.Name{
    static let myNotification = Notification.Name("AddRemove")
    static let myNotificationAdd = Notification.Name("AddToList")
    static let myNotificationCount = Notification.Name("CountSection")

}
