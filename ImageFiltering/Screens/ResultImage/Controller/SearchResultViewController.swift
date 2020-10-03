//
//  SearchResultViewController.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/2/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import UIKit

enum Section: String {
    case section1 = "Source1"
    case section2 = "Source2"
    case section3 = "Source3"
    case section4 = "Source4"
    
}

struct SectionState {
    var state: Bool
    var section: Section
}
class SearchResultViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var collectionView: UICollectionView!
    var queue2 = DispatchQueue(label: "mydata.image", attributes: .concurrent)
    var sectionTitle:[Section] = [.section1, .section2, .section3,.section4]
    
    var sourceNames:[Section] = [.section1, .section2, .section3,.section4]
    var imageDict: [Section: [UIImage]]? {
            queue2.sync {
                return storeImages
            }
            
    }
    var storeImages:[Section: [UIImage]] = [:]
    
    var imageData: [APIResponse]?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.showSpinner()
        self.tableView.register(ItemTableViewCell.nib(), forCellReuseIdentifier: ItemTableViewCell.identifier)
        self.configure(section: .section1, index: 0)
        self.observerSectionState()
        
    }
    
    func configure(section: Section, index: Int) {
       
        let sectionKey = self.sectionTitle[index]

        print("In configure")
        let mythreadGroup = DispatchGroup()
        guard let imageSource = self.imageData?[index],
            let imageFile = imageSource.image else {return}

            storeImages[sectionKey] = []
            for imageStr in imageFile {
                guard let stringUrl = imageStr.imageUrl, let url = URL(string: stringUrl) else { continue}
                mythreadGroup.enter()
                DispatchQueue.global().async(flags: .barrier) {
                    do {
                        //convert data to UIImage
                        let data  = try Data(contentsOf: url)
                        self.queue2.async(flags: .barrier) {
                            if let image = UIImage(data: data) {
                                self.storeImages[sectionKey]?.append(image)
                            }
                        }
                        mythreadGroup.leave()
                    }
                    catch {
                        print(error)
                        mythreadGroup.leave()
                    }
                }
        
                mythreadGroup.notify(queue: DispatchQueue.main) {
                    print("finished")
                    self.tableView.reloadData()
                    self.removeSpinner()
                }
                
            }
        
    }
    func addImageSection(section: Section) {
        if (storeImages.index(forKey: section) != nil) {
            print("has value just return!!!")
            return
        }
        var index:Int = 0
        switch section {
        case .section1:
           index = 0
        case .section2:
           index = 1
        case .section3:
           index = 2
        case .section4:
           index = 3
        }
        self.configure(section: section, index: index)
    }
    func removeImageSection(section: Section) {
        if let _ =  storeImages[section] {
            storeImages.removeValue(forKey: section)
            tableView.reloadData()
        }
    }
    func observerSectionState() {
        NotificationCenter.default.addObserver(self, selector: #selector(getNotification), name: .myNotification, object: nil)
    }
    @objc func getNotification(_ notification: Notification) {
        guard let data = notification.userInfo?["data"] as? SectionState else {return }
        if data.state {
            addImageSection(section: data.section)
            
        }
        else {
            removeImageSection(section: data.section)
        }
        
    }
    
    
}

extension SearchResultViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        sectionTitle.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        imageDict?[sectionTitle[section]]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ItemTableViewCell.identifier, for: indexPath) as? ItemTableViewCell
            else { fatalError("Unable to dequeReusableCell with identifier: ImageTableViewCell") }
        let sectionKey = sectionTitle[indexPath.section]
        if let imageValues = imageDict, let imageList = imageValues[sectionKey] {
            cell.configure(image: imageList[indexPath.row])
        }
        else {
            cell.configure(image: UIImage(named: "star")!)
        }
        return cell
    }
    
    
}











extension SearchResultViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sourceNames.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SourceCollectionViewCell", for: indexPath) as? SourceCollectionViewCell
            
            else { fatalError("Unable to deque collectionView with identity: SourceCollectionView") }
        cell.configure(section: sourceNames[indexPath.row])
        return cell
    }
    
    
}
