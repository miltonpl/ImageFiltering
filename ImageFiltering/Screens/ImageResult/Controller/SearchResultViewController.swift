//
//  SearchResultViewController.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/2/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import UIKit

class SearchResultViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.tableFooterView = UIView()
        }
    }
    @IBOutlet private weak var collectionView: UICollectionView!
    var queue2 = DispatchQueue(label: "mydata.image", attributes: .concurrent)
    var sectionTitle:[Section] = []
    var sourceNames:[Section] = [.splashbase, .pixabay, .pexels]
    var TotalSections = 0
    var imageDict: [Section: [PhotoDescription]]? {
        queue2.sync {
            return storeImages
        }
    }
    var storeImages:[Section: [PhotoDescription]] = [:]
    
    var imageData: [ResponseProtocol]?
    var imageDataDict: [Section: ResponseProtocol] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showSpinner()
        setupProperties()
        setupTableViewProperties()
    }
    func setupProperties() {
        
        guard let imageSource = self.imageData else {
            self.removeSpinner(); return
        }
        for item in imageSource {
            if item is Splashbase {
                guard let  response = item as? Splashbase, let list = response.image, !list.isEmpty else {
                    print("Empty + Splashbase")
                    continue
                }
                sectionTitle.append(.splashbase)
                TotalSections += 1
                imageDataDict[.splashbase] = item
            }
            else if item is PixaBay {
                guard let  response = item as? PixaBay, let list = response.photos, !list.isEmpty else {
                    print("Empty + PixaBay")
                    continue
                }
                sectionTitle.append(.pixabay)
                TotalSections += 1
                imageDataDict[.pixabay] = item
            }
                
            else if item is Pexels {
                guard let  response = item as? Pexels, let list = response.photos, !list.isEmpty else {
                    print("Empty +  Pexels")
                    continue
                }
                sectionTitle.append(.pexels)
                TotalSections += 1
                imageDataDict[.pexels] = item
            }
        }
        if TotalSections < 1 || imageSource.isEmpty {
            self.removeSpinner()
        }
    }
    
    func configure(section: Section) {
        switch section {
        case .splashbase:
            guard let apiResponseFirst = imageDataDict[.splashbase] as? Splashbase,
                let list = apiResponseFirst.image else{ return}
            splashbaseSource(imageFile: list, section: section)
            break
        case .pixabay:
            guard let apiResponseFirst = imageDataDict[.pixabay] as? PixaBay,
                let list = apiResponseFirst.photos else{ return}
            
            pixabaySource(imageFile: list, section: section)
            break
        case .pexels:
            guard let apiResponseThird = imageDataDict[.pexels] as? Pexels,
                let list = apiResponseThird.photos else{ return}
            pexelsSource(imageFile: list, section: section)
            break
        }
    }
    
    func splashbaseSource(imageFile: [ImageInfo], section: Section)  {
        
        let mythreadGroup = DispatchGroup()
        storeImages[section] = []
        for imageStr in imageFile {
            guard let stringUrl = imageStr.imageUrl, let url = URL(string: stringUrl) else { continue}
            var page: String?
            if let pageUrl = imageStr.lardgeImageUrl {
                page = pageUrl
            }
            mythreadGroup.enter()
            DispatchQueue.global().async(flags: .barrier) {
                do {
                    //convert data to UIImage
                    let data  = try Data(contentsOf: url)
                    self.queue2.async(flags: .barrier) {
                        if let image = UIImage(data: data) {
                            self.storeImages[section]?.append(PhotoDescription(image: image, author: nil, site: page, title: nil, source: "Splashbase"))
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
                self.tableView.reloadData()
                self.removeSpinner()
            }
        }
    }
    
    func pexelsSource(imageFile: [PhotoInfo], section: Section)  {
        let mythreadGroup = DispatchGroup()
        storeImages[section] = []
        for imageStr in imageFile {
            guard let sourceImage = imageStr.sourceImage, let stringUrl = sourceImage.large, let url = URL(string: stringUrl) else { continue}
            var photographerUrl: String?
            var photographer: String?
            if let pageURl = imageStr.protographerUrl, let user = imageStr.protographer {
                photographerUrl = pageURl
                photographer = user
            }
            
            mythreadGroup.enter()
            DispatchQueue.global().async(flags: .barrier) {
                do {
                    //convert data to UIImage
                    let data  = try Data(contentsOf: url)
                    self.queue2.async(flags: .barrier) {
                        if let image = UIImage(data: data) {
                            self.storeImages[section]?.append(PhotoDescription(image: image, author: photographer, site: photographerUrl, title: nil, source: "Pexels"))
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
                self.tableView.reloadData()
                self.removeSpinner()
            }
        }
    }
    
    func pixabaySource(imageFile: [HitsInfo], section: Section)  {
        let mythreadGroup = DispatchGroup()
        storeImages[section] = []
        for imageStr in imageFile {
            guard let stringUrl = imageStr.largeImageUrl, let url = URL(string: stringUrl) else { continue}
            var page: String?
            if let pageUrl = imageStr.pageUrl{
                page = pageUrl
            }
            mythreadGroup.enter()
            DispatchQueue.global().async(flags: .barrier) {
                do {
                    //convert data to UIImage
                    let data  = try Data(contentsOf: url)
                    self.queue2.async(flags: .barrier) {
                        if let image = UIImage(data: data) {
                            self.storeImages[section]?.append(PhotoDescription(image: image, author: nil, site: page, title: nil, source: "Pixabay"))
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
        sectionTitle.append(section)
        self.configure(section: section)
        postNotificationToCollectionViewCell(count: storeImages.count)
        
    }
    func removeImageSection(section: Section) {
        if let _ =  storeImages[section] {
            guard TotalSections > 1 else { return }
            storeImages.removeValue(forKey: section)
            sectionTitle.removeAll { $0 == section}
            postNotificationToCollectionViewCell(count: storeImages.count)
            
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
    
    func setupTableViewProperties() {
        self.tableView.register(ItemTableViewCell.nib(), forCellReuseIdentifier: ItemTableViewCell.identifier)
        self.observerSectionState()
        if !sectionTitle.isEmpty {
            for section in sectionTitle {
                self.configure(section: section)
            }
        }
    }
}

extension SearchResultViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        sectionTitle.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sectionTitle[section].rawValue
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
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let uiSwipe =  UISwipeActionsConfiguration(actions: [UIContextualAction(style: .normal, title: "Save", handler: { (action, view, completion) in
            let sectionKey = self.sectionTitle[indexPath.section]
            if let imageValues = self.imageDict, let imageList = imageValues[sectionKey] {
                self.postNotification(photo:imageList[indexPath.row])
                completion(true)
            }
            
        })])
        uiSwipe.performsFirstActionWithFullSwipe = false
        return uiSwipe
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
        cell.observerActiveSectionNotification()
        return cell
    }
}

extension SearchResultViewController {
    func postNotification(photo: PhotoDescription){
        let data:[String: PhotoDescription] = ["Add": photo]
        NotificationCenter.default.post(name: .myNotificationAdd, object: nil, userInfo: data)
    }
}

extension SearchResultViewController {
    func postNotificationToCollectionViewCell(count: Int){
        let items:[String: Int] = ["items": count]
        NotificationCenter.default.post(name: .myNotificationCount, object: nil, userInfo: items)
    }
}
