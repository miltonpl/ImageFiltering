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
    
    private var providersList: [Provider] = []
    private var searchWebWorkItem: DispatchWorkItem?
    private var queue = DispatchQueue(label: "mydata.queue", attributes: .concurrent)
    private var applyFilter: FilterType?
    private var providersInfo: [ProviderInfo] = []
    private var _photoSections: [PhotoSection] = []
    private var photoSections: [PhotoSection]? {
        queue.sync {
            return _photoSections
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Photo Search"
        searchBar.delegate = self
        setupProvider()
        setupSettingButton()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        self.tableView.separatorColor = .black
    }
    
    func setupSettingButton () {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(settingAction(_:)))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "My Collection", style: .plain, target: self, action: #selector(myColletionAction(_:)))
        
    }
    @objc func settingAction(_ sender: UIBarButtonItem ) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let settingViewController = storyboard.instantiateViewController(withIdentifier: "SettingViewController") as? SettingViewController else {
            fatalError("Unagle to instantiateViewController") }
        
        settingViewController.configure(providers: providersInfo)
        settingViewController.delegate = self
        let navController = UINavigationController(rootViewController: settingViewController)
        self.navigationController?.present(navController, animated: true, completion: nil)
    }
    @objc func myColletionAction(_ sender: UIBarButtonItem ) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let myCollectionViewController = storyboard.instantiateViewController(withIdentifier: "MyCollectionViewController") as?
            MyCollectionViewController else { fatalError("Unable to idenfity MyCollectionViewController") }
        self.navigationController?.pushViewController(myCollectionViewController, animated: true)
    }
    
    func loadSection(data: Any?, provider: Provider) {
        guard let dictionary = data as? [String: Any] else { return }
        var newList: [PhotoProtocol] = []
        switch provider.name {
        case Splash.name:
            guard let listImages = dictionary["images"] as? [[String: Any]], !listImages.isEmpty else { return }
            listImages .forEach { item in
                newList.append(SplashPhotoInfo(dict: item, name: Splash.name))
            }
            self._photoSections.append(PhotoSection(name: ProviderType.splash, photos: newList))
            
        case Pexels.name:
            guard let listImages = dictionary["photos"] as? [[String: Any]], !listImages.isEmpty else { return }
            listImages .forEach { item in
                newList.append(PexelsPhotoInfo(dict: item, name: Pexels.name))
            }
            self._photoSections.append(PhotoSection(name: ProviderType.pexels, photos: newList))
            
        case PixaBay.name:
            guard let listImages = dictionary["hits"] as? [[String: Any]], !listImages.isEmpty else { return }
            listImages .forEach { item in
                newList.append(PixabayPhotoInfo(dict: item, name: PixaBay.name))
            }
            self._photoSections.append(PhotoSection(name: ProviderType.pixaBay, photos: newList))
        default:
            print("not a provider!!!")
        }
    }
    // MARK: - GetDataFromServer Method
    func fetchData(text: String) {
        for provider in providersList where provider.isOn {
            var parameter = provider.parameter
            if provider.parameter["q"] != nil {
                parameter["q"] = text
            } else {
                parameter["query"] = text
            }
            DispatchQueue.main.async {
                
                self.myDispatchGroup.enter()
                ServiceManager.manager.request(urlString: provider.url, header: provider.header, parameters: parameter) { [provider] data, error in
                    
                    if let error = error { print(error) }
                    
                    self.queue.async(flags: .barrier) {
                        self.loadSection(data: data, provider: provider)
                        self.myDispatchGroup.leave()
                    }
                }
            }
        }
        
        myDispatchGroup.notify(queue: DispatchQueue.main) {
            
            self.tableView.reloadData()
            if let photoSections = self.photoSections {
                print("photoSection.count: In for loop ", photoSections.count)
                photoSections.forEach { print("sections: ", $0.name) }
            }
        }
    }
    func handleTextChange(_ text: String) {
        searchWebWorkItem?.cancel()
        if !(photoSections?.isEmpty ?? true) {
            _photoSections = []
        }
        searchWebWorkItem = DispatchWorkItem {
            print("DispatchWorkItem ", self.providersInfo)
            for (index, provider) in self.providersInfo.enumerated() where provider.isOn == true {
                self.providersList[index].isOn = true
            }
            
            self.fetchData(text: text)
            
            for index in 0 ..< self.providersList.count {
                self.providersList[index].isOn = false
            }
            
        }
        guard let searchItem = searchWebWorkItem else { return }
        DispatchQueue.global().asyncAfter(deadline: .now() + 3, execute: searchItem)
    }
    func setupProvider() {
        providersList.append(Provider(name: Splash.name, url: Splash.url, parameter: Splash.parameters, isOn: true))
        providersList.append(Provider(name: PixaBay.name, url: PixaBay.url, parameter: PixaBay.parameters, isOn: true))
        providersList.append(Provider(name: Pexels.name, url: Pexels.url, parameter:
            Pexels.parameters, header: Pexels.headers, isOn: true))
        providersInfo.append(ProviderInfo(name: .splash, isOn: true))
        providersInfo.append(ProviderInfo(name: .pixaBay, isOn: true))
        providersInfo.append(ProviderInfo(name: .pexels, isOn: true))
    }
}

extension ImageListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return photoSections?[section].name.rawValue ?? ""
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        photoSections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoSections?[section].photos?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let filterViewController = storyboard.instantiateViewController(withIdentifier: "FilterPhotoViewController") as? FilterPhotoViewController,
            let photosDetails = photoSections?[indexPath.section].photos?[indexPath.row] else {
                fatalError("Unable to instantiate vie controllerr with identity: FilterPhotoViewController") }
        
        filterViewController.configure(imageStringUrl: photosDetails.imageUrl ?? "", name: photosDetails.name.rawValue)
        let navController = UINavigationController(rootViewController: filterViewController)
        self.navigationController?.present(navController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ImageTableViewCell", for: indexPath)
            as? ImageTableViewCell else { fatalError("Unable to deque Tableview with ImageTableViewCell") }
        
        guard let photoDetails = photoSections?[indexPath.section].photos?[indexPath.row] else { fatalError("data not present") }
        
        cell.setProterties(urlStr: photoDetails.imageUrl, providerName: photoDetails.name.rawValue, applyFilter)
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
    
    func removeProvider(provider: ProviderInfo) {
        self._photoSections.removeAll { $0.name == provider.name }
        tableView.reloadData()
    }
    func addProvider() {
        guard  let text = searchBar.text, text.count >= 5 else { return }
        fetchData(text: text)
    }
}

extension ImageListViewController: SettingViewControllerDelegate {
    
    func applyFilterToImages(filter: FilterType) {
        
        if filter == .none {
            tableView.reloadData()
            applyFilter = nil
            
        } else {
            applyFilter = filter
            tableView.reloadData()
        }
    }
    
    func updateProvidersList(provider: ProviderInfo) {
        
        let indexProvider = updateProviders(provider: provider)
        if provider.isOn {
            if let index = indexProvider {
                addProvider()
                providersList[index].isOn = false
            }
            
        } else {
            removeProvider(provider: provider)
        }
    }
    
    func updateProviders(provider: ProviderInfo) -> Int? {
        for (index, currentProvider) in providersInfo.enumerated() where currentProvider.name == provider.name {
            self.providersInfo[index].isOn = provider.isOn
            self.providersList[index].isOn = provider.isOn
            return index
        }
        return nil
    }
}
