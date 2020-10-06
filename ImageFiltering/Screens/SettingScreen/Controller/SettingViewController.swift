//
//  SettingViewController.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/6/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.tableFooterView = UIView()
        }
    }
    var providerList: [ApiRequestType] = []
    override func viewDidLoad() {
        self.title = "Settings"
        super.viewDidLoad()
        setupLeftTabItem()
    }
    
    func setupLeftTabItem() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneInSettings(_:)))
    }
    func configure(providerList: [ApiRequestType] ) {
        self.providerList = providerList
    }
    
    @objc func doneInSettings(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        providerList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProviderTableViewCell", for: indexPath) as? ProviderTableViewCell else {
            fatalError("unable to dequeue tableView withIdentifier: ProviderTableViewCell") }
        cell.configure(providerList[indexPath.row].rawValue)
        return cell
    }
}
