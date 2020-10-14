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
        self.title = "Set Filter"
        self.setupTabBarItems()
        self.filterTypes = Constants.filterTypes
    }
    
    func setupTabBarItems() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelBarItem(_:)))
    }
    
    @objc func cancelBarItem(_ sender: UIBarButtonItem) {
        if let indexPath = indexPath {
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryType = .none
            tableView.deselectRow(at: indexPath, animated: false)
            delegate?.applyFilterToImagesInImageListViewController(filter: .none)
        }
    }
}

extension SelectFilterViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {

        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
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
