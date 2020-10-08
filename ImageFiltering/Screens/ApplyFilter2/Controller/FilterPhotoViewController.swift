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
    private var filterList: [FilterType] = []
    private var fiterPhotos: [(image: UIImage, filter: FilterType)] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    func configure(imageStringUrl: String) {
        print(imageStringUrl)
        guard let url = URL(string: imageStringUrl) else { return }
        self.downloadImage(with: url)
        addFilterList()
        print("filterList: ", filterList.count)
        print(originalImage ?? "no image")
        print(fiterPhotos)
        
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
                }
            } catch {
                print(error)
            }
        }
    }
}

extension FilterPhotoViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.fiterPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCollectionViewCell", for: indexPath) as? FilterCollectionViewCell
            else {
                  fatalError("Unable to dequeue (FilterTableViewCell) tableView In FilterViewController ")
                  }
       print("\(fiterPhotos[indexPath.row].filter)")
        cell.configure(image: fiterPhotos[indexPath.row].image, title: "\(fiterPhotos[indexPath.row].filter)")
        return cell
    }
}
extension FilterPhotoViewController {
  func setFilter(filters: [FilterType]) {
    let mygroup = DispatchGroup()
    for filter in filters {
        DispatchQueue.global().sync {
            mygroup.enter()
            let image = self.originalImage?.addFilter(filter: filter)
            if let newImage = image {
                self.fiterPhotos.append((image: newImage, filter: filter))
                mygroup.leave()
            } else {
                mygroup.leave()
            }
        }
    }
    mygroup.notify(queue: DispatchQueue.main) {
        print("Donde", self.fiterPhotos.count)
    }
   
  }
  
}
/*
extension UIImage {
    func addFilter(filter: FilterType ) -> UIImage? {
        let filter = CIFilter(name: filter.rawValue)
        //convert UIImage to CIImage and set as input
        let ciInput = CIImage(image: self)
        filter?.setValue(ciInput, forKey: "inputImage")
        //get output CIImage, render as CGImage First to retail proper UIImage scale
        let ciOutput = filter?.outputImage
        let ciContext = CIContext()
        guard let ciOutputImage = ciOutput, let ciOutputExtent = ciOutput?.extent
            else {
            print("ciOutput error ")
            return nil
        }
        let cgImage = ciContext.createCGImage(ciOutputImage, from: ciOutputExtent)
        guard let cgImageSuccesful = cgImage else {
            print("cgImage error ")
            return nil
        }
        //return image
        return UIImage(cgImage: cgImageSuccesful)
    }
}
*/
