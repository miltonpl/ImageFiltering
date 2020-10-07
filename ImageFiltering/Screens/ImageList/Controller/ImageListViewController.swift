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
            self.tableView.register(ImageTableViewCell.nib(), forCellReuseIdentifier: ImageTableViewCell.identifier)
        }
    }
    @IBOutlet private weak var searchBar: UISearchBar!
    
    let myDispatchGroup = DispatchGroup()
    
    private var providerList: [Provider] = []
    private var searchWebWorkItem: DispatchWorkItem?
    private var queue = DispatchQueue(label: "mydata.queue", attributes: .concurrent)
    private var providers: [ProviderInfo] = []
    private var _photoSections: [PhotoSection] = []
    private var photoSections: [PhotoSection]? {
        queue.sync {
            return _photoSections
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "My Photo Collection"
        searchBar.delegate = self
        setupProvider()
        setupSettingButton()
//        observerAPIState()
    }
    func setupSettingButton () {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(settingActionTabBar(_:)))
    }
    @objc func settingActionTabBar(_ sender: UIBarButtonItem ) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let settingViewController = storyboard.instantiateViewController(withIdentifier: "SettingViewController") as? SettingViewController else {
            fatalError("Unagle to instantiateViewController") }
        
        settingViewController.configure(providers: providers)
        
        let navController = UINavigationController(rootViewController: settingViewController)
        self.navigationController?.present(navController, animated: true, completion: nil)
        print("back from settingViewController: ", providerList)
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
            self._photoSections.append(PhotoSection(title: ProviderType.splash, photos: newList))
            
        case Pexels.name:
            guard let listImages = dictionary["photos"] as? [[String: Any]], !listImages.isEmpty else { return }
            listImages .forEach { item in
                newList.append(PexelsPhotoInfo(dict: item, name: "Pexels"))
            }
            self._photoSections.append(PhotoSection(title: ProviderType.pexels, photos: newList))
            
        case PixaBay.name:
            guard let listImages = dictionary["hits"] as? [[String: Any]], !listImages.isEmpty else { return }
            listImages .forEach { item in
                newList.append(PixabayPhotoInfo(dict: item, name: "PixaBay"))
            }
            self._photoSections.append(PhotoSection(title: ProviderType.pixaBay, photos: newList))
        default:
            print("not a provider!!!")
        }
    }
    // MARK: - GetDataFromServer Method
    func fetchData(text: String) {
        for provider in providerList {
            guard provider.state else { continue }
            var parameter = provider.parameter
            if provider.parameter["q"] != nil {
                parameter["q"] = text
            } else {
                parameter["query"] = text
            }
            myDispatchGroup.enter()
            DispatchQueue.main.async {
                self.queue.async(flags: .barrier) {
                    ServiceManager.manager.request(urlString: provider.url, header: provider.header, parameters: parameter) { [provider] data, error in
                        if let error = error {
                            print(error)
                        }
                        self.loadSection(data: data, provider: provider)
                        self.myDispatchGroup.leave()
                    }
                }
            }
        }
        myDispatchGroup.notify(queue: DispatchQueue.main) {
            self.tableView.reloadData()
            if let photoSections = self.photoSections {
                print("photoSection.count: ", photoSections.count)
            }
        }
    }
    func handleTextChange(_ text: String) {
        searchWebWorkItem?.cancel()
        if !(photoSections?.isEmpty ?? true) {
            _photoSections = []
        }
        searchWebWorkItem = DispatchWorkItem {
            self.fetchData(text: text)
        }
        guard let searchItem = searchWebWorkItem else { return }
        DispatchQueue.global().asyncAfter(deadline: .now() + 3, execute: searchItem)
    }
    func setupProvider() {
        providerList.append(Provider(name: Splash.name, url: Splash.url, parameter: Splash.parameters, state: true))
        providerList.append(Provider(name: PixaBay.name, url: PixaBay.url, parameter: PixaBay.parameters, state: true))
        providerList.append(Provider(name: Pexels.name, url: Pexels.url, parameter:
            Pexels.parameters, header: Pexels.headers, state: true))
        providers.append(ProviderInfo(name: .splash, isOn: true))
        providers.append(ProviderInfo(name: .pixaBay, isOn: true))
        providers.append(ProviderInfo(name: .pexels, isOn: true))
    }
}

extension ImageListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return photoSections?[section].title.rawValue ?? ""
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        photoSections?.count ?? 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoSections?[section].photos?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ImageTableViewCell", for: indexPath)
            as? ImageTableViewCell else { fatalError("Unable to deque Tableview with ImageTableViewCell") }
        
        guard let sectionsArray = photoSections, let photos = sectionsArray[indexPath.section].photos, let urlStr = photos[indexPath.row].imageUrl, let name = photos[indexPath.row].name  else {
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
extension ImageListViewController {
    
    // MARK: - Notification addObserver
//    func observerAPIState() {
//        // Register to receive notification in your class
//        NotificationCenter.default.addObserver(self, selector: #selector(getNotification(_:)), name: .myNotification, object: nil)
//    }
//    @objc func getNotification(_ notification: Notification) {
        /*
         
        guard let provider = notification.userInfo?["api"] as? APIState else { return }
        
        let indexOfProviderState = providerState.firstIndex(where: { $0.name == provider.name})
        let indexList = providerList.firstIndex(where: { $0.name == provider.name.rawValue})
        guard let indexProvider = indexList, let index = indexOfProviderState  else { return }
        providerState[index] = provider
        var providerWillChanged = providerList[indexProvider]
        
        if provider.state {
            providerWillChanged.state = true
            
            addProvider(provider: provider)
        } else {
            providerWillChanged.state = false
            
            removeProvider(provider: provider)
        }
        providerList[indexProvider] = providerWillChanged
        var activeProviders = 0
        providerState.forEach { provider in
            if provider.state {
                activeProviders += 1
            }
        }
        postNotificationToSettingTableViewCell(activeProviders: activeProviders )
        **/
    }
    //Some work
    /*
    func removeProvider(provider: APIState) {
        print("romoveProvider: ", provider.name)
        print("keys:", _dataResponse.keys)
        guard dataResponse?.count ?? 0 > 1 else { return }
        self._dataResponse.removeValue(forKey: provider.name)
        self._sectionList.removeAll { $0 == provider.name}
        tableView.reloadData()
        print("afterRemoal: ", _dataResponse.keys)
    }
    func addProvider(provider: APIState) {
        guard  let text = searchBar.text, text.count >= 5 else { return }
        fetchData(text: text)
    }
    func postNotificationToSettingTableViewCell(activeProviders: Int) {
        let data: [String: Int] = ["switch": activeProviders]
        NotificationCenter.default.post(name: .myNotification2, object: nil, userInfo: data)
    }
    **/
//}
