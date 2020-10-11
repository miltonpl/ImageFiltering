//
//  MyCollectionViewController.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/10/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import UIKit

class MyCollectionViewController: UIViewController {

     @IBOutlet weak var collectionView: UICollectionView! {
            didSet {
                self.collectionView.register(MyCollectionViewCell.nib(), forCellWithReuseIdentifier: MyCollectionViewCell.identifier)
            }
        }
    var myPhotos: [PhotoInfo] = []
        override func viewDidLoad() {
            super.viewDidLoad()
            
        }
    func configure(photoInfo: PhotoInfo) {
        myPhotos.append(photoInfo)
        myPhotos.append(photoInfo)
        myPhotos.append(photoInfo)

        }
 
    }

    extension MyCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            self.myPhotos.count
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
           
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCollectionViewCell", for: indexPath) as?
                MyCollectionViewCell
                else {
                    fatalError("Unable to dequeue (FilterTableViewCell) tableView In FilterViewController ")
            }
            cell.configure(photoInfo: myPhotos[indexPath.row])
            return cell
        }
    }
