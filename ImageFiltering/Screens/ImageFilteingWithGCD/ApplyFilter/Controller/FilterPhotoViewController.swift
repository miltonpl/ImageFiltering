//
//  FilterPhotoViewController.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/8/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import UIKit

class FilterPhotoViewController: UIViewController {
    // MARK: - IBOutlet Store Properties
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            self.collectionView.register(FilterCollectionViewCell.nib(), forCellWithReuseIdentifier: FilterCollectionViewCell.identifier)
        }
    }
    @IBOutlet weak var mainImageView: UIImageView! {
        didSet {
            self.mainImageView.layer.borderWidth = 3
            self.mainImageView.layer.borderColor = UIColor.black.cgColor
            self.mainImageView.contentMode = .scaleAspectFill
        }
    }
    
    // MARK: - Store Properties
    private var originalImage: UIImage?
    private let  activityIndicator = UIActivityIndicatorView()
    private var filterList: [FilterType] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    private var photoModel: PhotoModel?
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Apply Filter"
        self.activityIndicator.frame = mainImageView.bounds
        self.setupTabBarItems()
        self.setupImageView()
    }
    
    // MARK: - ViewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.filterList = Constants.filterTypes
    }
    
    // MARK: - Setup Tab BarItem
    func setupTabBarItems() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveBarItem(_:)))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelBarItem(_:)))
    }
    // MARK: - Save BarItem
    @objc func saveBarItem(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let myCollectionViewController = storyboard.instantiateViewController(withIdentifier: "MyCollectionViewController") as?
            MyCollectionViewController else { fatalError("Unable to idenfity MyCollectionViewController") }
        if let photoModel = photoModel {
            myCollectionViewController.configure(photoModel)
            self.navigationController?.pushViewController(myCollectionViewController, animated: true)
        }
    }
    // MARK: - Cancel BarItem
    @objc func cancelBarItem(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    // MARK: - Setup Configure
    func configure(imageStringUrl: String, name: String) {
        self.photoModel = PhotoModel(url: imageStringUrl, filterType: .none, providerName: name)
    }
    // MARK: - Setup Image view
    func setupImageView() {
        self.startActivityIndicator()
        if let strUrl = self.photoModel?.url, let url = URL(string: strUrl) {
            downloadImage(with: url)
        } else {
            self.mainImageView.image = Constants.failedImage
        }
    }
    // MARK: - Activity Indicator
    func startActivityIndicator() {
        self.mainImageView.addSubview(activityIndicator)
        self.activityIndicator.startAnimating()
    }
    
    func stopActivityIndicator() {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.removeFromSuperview()
    }
    
    // MARK: - Download Image for mainImageview
    func downloadImage(with url: URL) {
        DispatchQueue.global().async {
            do {
                let data = try Data(contentsOf: url)
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    self.originalImage = image
                    self.mainImageView.image = image
                    self.stopActivityIndicator()
                }
            } catch {
                print(error)
                DispatchQueue.main.async {
                    self.originalImage = Constants.failedImage
                    self.mainImageView.image = Constants.failedImage
                    self.stopActivityIndicator()
                }
            }
        }
    }
}
// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension FilterPhotoViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.filterList.count
    }
    
    // MARK: - Did SelectItemAt
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        startActivityIndicator()
        guard let image = originalImage else { return }
        self.activityIndicator.startAnimating()
        if filterList[indexPath.row] == .none {
            self.mainImageView.image = image
            stopActivityIndicator()
        } else {
            self.photoModel?.filterType = filterList[indexPath.row]
            self.mainImageView.applyFilterToImage(image, filterList[indexPath.row])
            stopActivityIndicator()
        }
    }
    
    // MARK: - Cell For itemAt
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCollectionViewCell", for: indexPath) as?
            FilterCollectionViewCell
            else {
                fatalError("Unable to dequeue (FilterTableViewCell) tableView In FilterViewController ")
        }
        if let image = originalImage {
            cell.configure(image: image, filter: filterList[indexPath.row])
            
        } else {
            print("NO image Url !! in Filter View Controller")
        }
        return cell
    }
}
