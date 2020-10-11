//
//  SelectFilterViewController.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/9/20.
//  Copyright © 2020 Milton. All rights reserved.
//
import UIKit
import CoreImage

protocol SelectFilterViewControllerDelegate: AnyObject {
    
    func applyFilterToImagesInImageListViewController(filter: FilterType)
}

class SelectFilterViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.tableFooterView = UIView()
        }
    }
       
    weak var delegate: SelectFilterViewControllerDelegate?
    var filterTypes: [FilterType] = []
    var indexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFilterType()
        setupTabBarItems()
    }
    
    func setupTabBarItems() {
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelBarItem(_:)))
    }
    
    @objc func cancelBarItem(_ sender: UIBarButtonItem) {
        if let indexPath = indexPath {
            print("cancelBarItem", indexPath)
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryType = .none
            tableView.deselectRow(at: indexPath, animated: false)
            delegate?.applyFilterToImagesInImageListViewController(filter: .none)
            
        }
    }
   
    func setupFilterType() {
        filterTypes = [.none, .chrome, .fade, .instant, .mono, .noir, .process, .tonal, .transfer]
        
    }
}

extension SelectFilterViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {

        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
            print(".none", indexPath.row)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
            print("index path:", indexPath)
            self.indexPath = indexPath
            delegate?.applyFilterToImagesInImageListViewController(filter: filterTypes[indexPath.row])

        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filterTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SelectFilterTableViewCell", for: indexPath) as?   SelectFilterTableViewCell else {
            fatalError("Unable to dequeue (FilterTableViewCell) tableView In FilterViewController ")
        }
        cell.configure(filter: filterTypes[indexPath.row])
        return cell
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
