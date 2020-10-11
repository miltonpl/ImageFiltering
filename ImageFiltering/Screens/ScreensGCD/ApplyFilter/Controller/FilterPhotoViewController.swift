//
//  FilterPhotoViewController.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/8/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import UIKit

class FilterPhotoViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            self.collectionView.register(FilterCollectionViewCell.nib(), forCellWithReuseIdentifier: FilterCollectionViewCell.identifier)
        }
    }
    @IBOutlet weak var itemImageView: UIImageView! {
        didSet {
            self.itemImageView.contentMode = .scaleAspectFill
        }
    }
    private var originalImage: UIImage?
    private var queue = DispatchQueue(label: "my.queue.fiter", attributes: .concurrent)
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private var filterList: [FilterType] = []
    private var imageUrl: String?
    private var providerName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.itemImageView.layer.borderWidth = 3
        self.itemImageView.layer.borderColor = UIColor.black.cgColor
        self.activityIndicator.startAnimating()
        self.addFilterList()
        self.setupTabBarItems()
        collectionView.scalesLargeContentImage = true
//        tableView.rowHeight = UITableView.automaticDimension
//        tableView.estimatedRowHeight = 200
        
    }
    func setupTabBarItems() {

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveBarItem(_:)))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelBarItem(_:)))
      }
    
    @objc func saveBarItem(_ sender: UIBarButtonItem) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let myCollectionViewController = storyboard.instantiateViewController(withIdentifier: "MyCollectionViewController") as?
            MyCollectionViewController else { fatalError("Unable to idenfity MyCollectionViewController") }
        if let image = self.itemImageView.image, let name = providerName {
            myCollectionViewController.configure(photoInfo: PhotoInfo(image: image, title: name))
            self.navigationController?.pushViewController(myCollectionViewController, animated: true)
        }
    }

    @objc func cancelBarItem(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
       }
    
    func configure(imageStringUrl: String, name: String) {
        self.imageUrl = imageStringUrl
        self.providerName = name
        guard let url = URL(string: imageStringUrl) else { return }
        self.downloadImage(with: url)
    }
    
    func addFilterList() {
        filterList.append(.none)
        filterList.append(.chrome)
        filterList.append(.fade)
        filterList.append(.instant)
        filterList.append(.noir)
        filterList.append(.tonal)
        filterList.append(.transfer)
        filterList.append(.process)
    }
    
    func downloadImage(with url: URL) {
        DispatchQueue.global().async {
            do {
                let data = try Data(contentsOf: url)
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    self.itemImageView.image = image
                    self.originalImage = image
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                }
                
            } catch {
                print(error)
            }
        }
    }
}

extension FilterPhotoViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.filterList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.activityIndicator.startAnimating()
        if filterList[indexPath.row] == .none {
            guard let image = originalImage else { return }
            itemImageView.image = image
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            
        } else {
            if let imageUrl = self.imageUrl {
                DispatchQueue.global().async {
                    ServiceManager.manager.applyFilter(imageUrl: imageUrl, filter: self.filterList[indexPath.row]) { image in
                        guard let image = image else { print("Ops no Image"); return }
                        DispatchQueue.main.async {
                            self.itemImageView.image = image
                            self.activityIndicator.stopAnimating()
                            self.activityIndicator.isHidden = true
                            
                            print("image success")
                        }
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCollectionViewCell", for: indexPath) as?
            FilterCollectionViewCell
            else {
                fatalError("Unable to dequeue (FilterTableViewCell) tableView In FilterViewController ")
        }
        if let imageUrl = self.imageUrl {
            cell.configure(imageUrl: imageUrl, filter: filterList[indexPath.row])
            
        } else {
            print("NO image Url !! in Filter View Controller")
        }
        return cell
    }
}
