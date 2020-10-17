//
//  SettingViewController.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/6/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import UIKit
protocol SettingViewControllerDelegate: AnyObject {
    
    func setupAddReveProvider(provider: ProviderInfo)
    func applyFilterToImages(filter: FilterType)
}

class SettingViewController: UIViewController {
    
    @IBOutlet weak var selectFilterButton: UIButton!
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            self.tableView.tableFooterView = UIView()
            self.tableView.allowsSelection = false
            self.tableView.register(ProviderTableViewCell.nib(), forCellReuseIdentifier: ProviderTableViewCell.identifier )
        }
    }
    private var providers: [ProviderInfo] = [] {
        didSet {
            self.tableView?.reloadData()
        }
    }
    
    weak var delegate: SettingViewControllerDelegate?
    
    lazy var customTableViewCell: UITableViewCell = {
        let customTableViewCell = UITableViewCell()
        customTableViewCell.frame = selectFilterButton.bounds
        customTableViewCell.accessoryType = .disclosureIndicator
        customTableViewCell.isUserInteractionEnabled = false
        return customTableViewCell
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        self.setupLeftTabItem()
        self.setupSelectedButton()
    }
    
    func setupSelectedButton() {
        self.selectFilterButton.setTitle( "Set Filter To All Images", for: .normal)
        self.selectFilterButton.addSubview(customTableViewCell)
    }
    
    func setupLeftTabItem() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneInSettings(_:)))
    }
    
    func configure(providers: [ProviderInfo] ) {
        self.providers = providers
    }
    
    @objc func doneInSettings(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectedButton(_ sender: UIButton ) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard  let applyFilterViewController = storyboard.instantiateViewController(withIdentifier: "SelectFilterViewController") as? SelectFilterViewController else {
            fatalError("Anable to instantiateViewController in Setting View Controller")
        }
        applyFilterViewController.delegate = self
        self.navigationController?.pushViewController(applyFilterViewController, animated: true)
    }
}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        providers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProviderTableViewCell", for: indexPath) as? ProviderTableViewCell else {
            fatalError("unable to dequeue tableView withIdentifier: ProviderTableViewCell") }
        cell.configure(providers[indexPath.row])
        cell.delegate = self
        return cell
    }
}
// MARK: - Update Status About Active Provider
extension SettingViewController: ProviderTableViewCellDelegate {
    
    func notifyUser() {
        let alertController = UIAlertController(title: "Active Providers", message: "At least one provider should be active, thanks", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alertController, animated: true)
    }
    
    func canChangeStatus() -> Bool {
        return providers.filter { $0.isOn }.count > 1
    }
    
    func didChangeStatus(provider: ProviderInfo) {
        if let indexProvider = self.providers.firstIndex(where: { $0.name == provider.name }) {
            self.providers[indexProvider] = provider
            delegate?.setupAddReveProvider(provider: provider)
        }
    }
}

// MARK: - Pass Delegation To ImageListViewController
extension SettingViewController: SelectFilterViewControllerDelegate {
    
    func applyFilterToImagesInImageListViewController(filter: FilterType) {
        delegate?.applyFilterToImages(filter: filter)
    }
    
}
