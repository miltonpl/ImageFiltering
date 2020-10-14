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
    
    var myPhotos: [PhotoModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let flowlayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowlayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            let itemWidth = self.collectionView.frame.width - 30/2
            flowlayout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        }
    }
    
    func configure(_ photoModel: PhotoModel) {
        myPhotos.append(photoModel)
        myPhotos.append(photoModel)
        myPhotos.append(photoModel)
    }
}

extension MyCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.myPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCollectionViewCell", for: indexPath) as?
            MyCollectionViewCell
            else {
                fatalError("Unable to dequeue (FilterTableViewCell) tableView In FilterViewController ")
        }
        cell.configure(myPhotos[indexPath.row])
        return cell
    }
}
