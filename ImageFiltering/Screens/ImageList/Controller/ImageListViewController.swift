//
//  ViewController.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/2/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import UIKit

class ImageListViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            self.tableView.tableFooterView = UIView()
        }
    }
    @IBOutlet private weak var searchBar: UISearchBar!
    var providerList: [Provider] = []
    private let myGroupForJosonDecoder = DispatchGroup()
    private var searchWebWorkItem: DispatchWorkItem?
    private var queue = DispatchQueue(label: "mydata.queue", attributes: .concurrent)
    private var _sectionList: [ApiRequestType] = []
    private var sectionList: [ApiRequestType] {
        queue.sync {
            return _sectionList
        }
    }
    private var _dataResponse: [ApiRequestType: [PhotoProtocol]] = [:]
    private var dataResponse: [ApiRequestType: [PhotoProtocol]]? {
        queue.sync {
            return _dataResponse
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "My Photo Collection"
        tableView.register(ImageTableViewCell.nib(), forCellReuseIdentifier: ImageTableViewCell.identifier)
        searchBar.delegate = self
        setupProvider()
        setupSettingButton()
    }
    func setupSettingButton () {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(settingActionTabBar(_:)))
    }
    @objc func settingActionTabBar(_ sender: UIBarButtonItem ) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let settingViewController = storyboard.instantiateViewController(withIdentifier: "SettingViewController") as? SettingViewController else {
            fatalError("Unagle to instantiateViewController") }
        let navController = UINavigationController(rootViewController: settingViewController)
        self.navigationController?.present(navController, animated: true, completion: nil)
        
    }
    func loadSection(data: Any?, provider: Provider) {
        guard let dictionary = data as? [String: Any] else { return }
        var newList: [PhotoProtocol] = []
        switch provider.name {
        case Splash.name:
             guard let listImages = dictionary["images"] as? [[String: Any]], !listImages.isEmpty else { return }
             listImages .forEach { item in
                 newList.append(SplashPhotoInfo(dict: item, name: "Splash"))
             }
             self._dataResponse[.splash] = newList
             self._sectionList.append(.splash)
            
        case Pexels.name:
             guard let listImages = dictionary["photos"] as? [[String: Any]], !listImages.isEmpty else { return }
             listImages .forEach { item in
                     newList.append(PexelsPhotoInfo(dict: item, name: "Pexels"))
             }
             self._dataResponse[.pexels] = newList
             self._sectionList.append(.pexels)

        case PixaBay.name:
             guard let listImages = dictionary["hits"] as? [[String: Any]], !listImages.isEmpty else { return }
             listImages .forEach { item in
                 newList.append(PixabayPhotoInfo(dict: item, name: "PixaBay"))
             }
             self._dataResponse[.pixaBay] = newList
             self._sectionList.append(.pixaBay)

        default:
                print("not a provider!!!")
            }
    }
    // MARK: - GetDataFromServer Method
    func fetchData(text: String) {
        for provider in providerList {
            print(provider.name)
            var parameter = provider.parameter
            if provider.parameter["q"] != nil {
                parameter["q"] = text
            } else {
                parameter["query"] = text
            }
            myGroupForJosonDecoder.enter()
            DispatchQueue.main.async {
                self.queue.async(flags: .barrier) {
                    ServiceManager.manager.request(urlString: provider.url, header: provider.header, parameters: parameter) { [provider] data, error in
                        if let error = error {
                            print(error)
                        }
                        self.loadSection(data: data, provider: provider)
                        self.myGroupForJosonDecoder.leave()
                    }
                }
            }
        }
        myGroupForJosonDecoder.notify(queue: DispatchQueue.main) {
            self.tableView.reloadData()
        }
    }
    func handleTextChange(_ text: String) {
        searchWebWorkItem?.cancel()
        if !(dataResponse?.isEmpty ?? true) {
            _dataResponse = [:]
            _sectionList = []
        }
        searchWebWorkItem = DispatchWorkItem {
        self.fetchData(text: text)
        }
        guard let searchItem = searchWebWorkItem else { return }
        DispatchQueue.global().asyncAfter(deadline: .now() + 3, execute: searchItem)
    }
    func setupProvider() {
        providerList.append(Provider(name: Splash.name, url: Splash.url, parameter: Splash.parameters))
        providerList.append(Provider(name: PixaBay.name, url: PixaBay.url, parameter: PixaBay.parameters))
        providerList.append(Provider(name: Pexels.name, url: Pexels.url, parameter: Pexels.parameters, header: Pexels.headers))
    }
}

extension ImageListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sectionList[section].rawValue
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        sectionList.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let data = dataResponse {
           return data[sectionList[section]]?.count ?? 0
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ImageTableViewCell", for: indexPath)
            as? ImageTableViewCell else { fatalError("Unable to deque Tableview with ImageTableViewCell") }
        guard let data = dataResponse, let list = data[sectionList[indexPath.section]], let urlStr = list[indexPath.row].imageUrl, let name = list[indexPath.row].name  else {
            fatalError("data not present")
        }
        cell.setProterties(urlStr: urlStr, providerName: name)
        return cell
    }
}

extension ImageListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count >= 5 {
            let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            if let stringForURL = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                handleTextChange(stringForURL)
            }
        }
    } // called when text changes (including clear)
}
