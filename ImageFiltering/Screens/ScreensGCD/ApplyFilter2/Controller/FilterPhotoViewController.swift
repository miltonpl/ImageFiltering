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
    @IBOutlet weak var itemImageView: UIImageView!
    private var originalImage: UIImage?
    private var queue = DispatchQueue(label: "my.queue.fiter", attributes: .concurrent)
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private var filterList: [FilterType] = []
    //    private var _fiterPhotos: [(image: UIImage, filter: FilterType)] = []
    private var _fiterPhotos: [FilterImage] = []
    private var fiterPhotos: [FilterImage]? {
        queue.sync {
            return _fiterPhotos
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.itemImageView.layer.borderWidth = 3
        self.itemImageView.layer.borderColor = UIColor.black.cgColor
        self.activityIndicator.startAnimating()
        
    }
    
    func configure(imageStringUrl: String) {
        print(imageStringUrl)
        guard let url = URL(string: imageStringUrl) else { return }
        self.downloadImage(with: url)
        addFilterList()
        print("filterList: ", filterList.count)
        print(originalImage ?? "no image")
        //        print(fiterPhotos ?? "")
        //        self.setFilter(filters: self.filterList)
    }
    
    func addFilterList() {
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
                    self.setFilter(filters: self.filterList)
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
        self.fiterPhotos?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let filterImages = fiterPhotos {
            self.itemImageView.image = filterImages[indexPath.row].image
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCollectionViewCell", for: indexPath) as?
            FilterCollectionViewCell, let filterImages = fiterPhotos
            else {
                fatalError("Unable to dequeue (FilterTableViewCell) tableView In FilterViewController ")
        }
        
        cell.configure(image: filterImages[indexPath.row].image, filter: filterImages[indexPath.row].filter)
        
        return cell
    }
}

extension FilterPhotoViewController {
    func setFilter(filters: [FilterType]) {
        let mygroup = DispatchGroup()
        for filter in filters {
            DispatchQueue.global().sync {
                mygroup.enter()
                let image = self.originalImage?.applyFilter(filter: filter)
                queue.async(flags: .barrier) {
                    if let newImage = image {
                        self._fiterPhotos.append(FilterImage(image: newImage, filter: filter))
                        mygroup.leave()
                    } else {
                        mygroup.leave()
                    }
                }
                
            }
        }
        mygroup.notify(queue: DispatchQueue.main) {
            print("Donde", self._fiterPhotos.count)
            self.collectionView.reloadData()
        }
    }
    /*
    func showLoading() {
//        originalButtonText = self.titleLabel?.text
//        self.setTitle("", for: .normal)
        guard activityIndicator == nil else { return }
        activityIndicator = createActivityIndicator()
        showSpinning()
    }
    func hideLoading() {
//        self.setTitle(originalButtonText, for: .normal)
        activityIndicator.stopAnimating()
    }
    private func createActivityIndicator() -> UIActivityIndicatorView {
           let activityIndicator = UIActivityIndicatorView()
           activityIndicator.hidesWhenStopped = true
           activityIndicator.color = .lightGray
           return activityIndicator
       }
    private func showSpinning() {
           activityIndicator.translatesAutoresizingMaskIntoConstraints = false
           itemImageView.addSubview(activityIndicator)
           centerActivityIndicatorInButton()
           activityIndicator.startAnimating()
       }
    private func centerActivityIndicatorInButton() {
          let xCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: activityIndicator, attribute: .centerX, multiplier: 1, constant: 0)
          itemImageView.addConstraint(xCenterConstraint)
          
          let yCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: activityIndicator, attribute: .centerY, multiplier: 1, constant: 0)
          itemImageView.addConstraint(yCenterConstraint)
      }
 */
}
/*
class LoadingButton: UIButton {
    var originalButtonText: String?
    var activityIndicator: UIActivityIndicatorView!
    
    func showLoading() {
        originalButtonText = self.titleLabel?.text
        self.setTitle("", for: .normal)
        
        if (activityIndicator == nil) {
            activityIndicator = createActivityIndicator()
        }
        
        showSpinning()
    }
    
    func hideLoading() {
        self.setTitle(originalButtonText, for: .normal)
        activityIndicator.stopAnimating()
    }
    
    private func createActivityIndicator() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .lightGray
        return activityIndicator
    }
    
    private func showSpinning() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(activityIndicator)
        centerActivityIndicatorInButton()
        activityIndicator.startAnimating()
    }
    
    private func centerActivityIndicatorInButton() {
        let xCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: activityIndicator, attribute: .centerX, multiplier: 1, constant: 0)
        self.addConstraint(xCenterConstraint)
        
        let yCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: activityIndicator, attribute: .centerY, multiplier: 1, constant: 0)
        self.addConstraint(yCenterConstraint)
    }
}
*/
