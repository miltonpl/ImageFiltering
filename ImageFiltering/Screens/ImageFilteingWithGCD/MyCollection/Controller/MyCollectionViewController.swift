//
//  MyCollectionViewController.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/10/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import UIKit

class MyCollectionViewController: UIViewController {
    // MARK: - @IBOutlet
    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            self.collectionView.register(MyCollectionViewCell.nib(), forCellWithReuseIdentifier: MyCollectionViewCell.identifier)
        }
    }
    // MARK: - Store Properties
    private var myPhotos: [PhotoModel] = []
    private var fileName = "PhotosFile.json"
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "My Collection"
        self.setupCollectioViewCell()
        self.loadJsonData()
    }
    // MARK: - ViewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        storeMyphotosInJson()
    }
    // MARK: - Configure Data
    func configure(_ photoModel: PhotoModel) {
        myPhotos.append(photoModel)
        self.setupTabBarImte()
    }
    
    // MARK: - Load Json Data to myPhotos
    func loadJsonData() {
        DataManager.shared.jsonReadData(fileName: fileName ) { (photos, error) in
            guard let photos = photos else { print( error ?? ""); return }
            photos.forEach { myPhotos.append($0) }
        }
    }
    
    // MARK: - Store Myphotos in Json File
    func storeMyphotosInJson() {
        DataManager.shared.writeDataInJsonFormat(fileName: fileName, photos: myPhotos) { error in
            if let error = error {
                print(error)
            }
        }
    }
    
    // MARK: - Setup Done Bar Buttom Item
    func setupTabBarImte() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction(_:)))
    }
    
    @objc func doneAction(_ sender: UIBarButtonItem) {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Setup Collection View Cell
    func setupCollectioViewCell() {
        guard let flowlayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let numberOfCells: CGFloat = 1.0
        flowlayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        let padding = 20 + flowlayout.minimumLineSpacing * (numberOfCells - 1.0)
        let size = (self.collectionView.frame.width - padding)/numberOfCells
        flowlayout.itemSize = CGSize(width: size, height: size)
    }
}

// MARK: - UICollectioView Delegate, UICollectionViewDataSource
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
