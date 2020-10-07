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
            self.tableView.tableFooterView = UIView()
            self.tableView.register(ProviderTableViewCell.nib(), forCellReuseIdentifier: ProviderTableViewCell.identifier )
        }
    }
    private var providers: [ProviderInfo] = [] {
        didSet {
            self.tableView?.reloadData()
        }
    }
    override func viewDidLoad() {
        self.title = "Settings"
        super.viewDidLoad()
        self.setupLeftTabItem()
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
extension SettingViewController: ProviderTableViewCellDelegate {
    func canChangeStatus() -> Bool {
        var activeProvider = 0
        providers.forEach { providers in
            if providers.isOn {
                activeProvider += 1
            }
        }
        return activeProvider > 1
    }

    func didChangeStatus(provider: ProviderInfo) {
        if let indexProvider = self.providers.firstIndex(where: { $0.name == provider.name }) {
            self.providers[indexProvider] = provider
        }
    }
    
}
