//
//  ApplyFilterViewController.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/7/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import UIKit
import CoreImage
class ApplyFilterViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.tableFooterView = UIView()
            self.tableView.allowsSelection = false
        }
    }
    @IBOutlet weak var itemImageView: UIImageView!
    private var originalImage: UIImage?
    var filterList: [FilterType] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        addFilterList()
    }
    
    func configure(imageStringUrl: String) {
        print(imageStringUrl)
        guard let url = URL(string: imageStringUrl) else { return }
        self.downloadImage(with: url)
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
                }
            } catch {
                print(error)
            }
        }
    }
}

extension ApplyFilterViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filterList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FilterTableViewCell", for: indexPath) as? FilterTableViewCell else {
            fatalError("Unable to dequeue (FilterTableViewCell) tableView In FilterViewController ")
            }
        print("Cell")
        cell.configure(name: "\(filterList[indexPath.row])", filter: filterList[indexPath.row])
        cell.delegate = self
        return cell
    }
}
extension ApplyFilterViewController: FilterTableViewCellDelegate {
  func setFilter(filter: FilterType) {
    let image = self.originalImage?.applyFilter(filter: filter)
    self.itemImageView.image = image
  }
  
}
extension UIImage {
    func applyFilter(filter: FilterType ) -> UIImage? {
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
