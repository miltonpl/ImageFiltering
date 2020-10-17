//
//  ViewController.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/2/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import UIKit

class ImageListViewController: UIViewController {
    // MARK: - IBOutlet Store Properties
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            self.tableView.tableFooterView = UIView()
            self.tableView.separatorColor = .black
            self.tableView.rowHeight = 300
            self.tableView.register(ImageTableViewCell.nib(), forCellReuseIdentifier: ImageTableViewCell.identifier)
        }
    }
    @IBOutlet private weak var searchBar: UISearchBar! {
        didSet {
            self.searchBar.delegate = self
            self.searchBar.placeholder = "Search Image"
            self.searchBar.showsCancelButton = true
        }
    }
    
    // MARK: - Lazy var Implementation
    lazy var label: UILabel = {
           let label = UILabel()
           label.text = "Search any images and \nsaved to your favotire collection"
           label.font = .boldSystemFont(ofSize: 20.0)
           label.textAlignment = .center
           label.numberOfLines = 0
           return label
       }()
    lazy var storyBoard: UIStoryboard = {
          var storyboard = UIStoryboard(name: "Main", bundle: nil)
          return storyboard
      }()
    
    // MARK: - Store Properies Implementation
    private let myDispatchGroup = DispatchGroup()
    
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
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Using GCD"
        self.setupSettingAction()
        self.providersInfo = Constants.providerInfo
        self.providersList = Constants.providers
        self.showNoResults()
        self.showNoResults()
    }
    
    // MARK: - Setup Bar buttons
    func setupSettingAction () {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(settingAction(_:)))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Favorites", style: .plain, target: self, action: #selector(myColletionAction(_:)))
        
    }
    
    // MARK: - Instantiate My CollectionView Controller
    @objc func settingAction(_ sender: UIBarButtonItem ) {
        guard let settingViewController = storyBoard.instantiateViewController(withIdentifier: "SettingViewController") as? SettingViewController else {
            fatalError("Unagle to instantiateViewController") }
        
        settingViewController.configure(providers: providersInfo)
        settingViewController.delegate = self
        let navController = UINavigationController(rootViewController: settingViewController)
        self.navigationController?.present(navController, animated: true, completion: nil)
    }
    
    // MARK: - Instantiate My CollectionView Controller
    @objc func myColletionAction(_ sender: UIBarButtonItem ) {
        guard let myCollectionViewController = storyBoard.instantiateViewController(withIdentifier: "MyCollectionViewController") as?
            MyCollectionViewController else { fatalError("Unable to idenfity MyCollectionViewController") }
        self.navigationController?.pushViewController(myCollectionViewController, animated: true)
    }
    
    // MARK: - Load Data Section In _photoSections
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
    // MARK: - Setup Providers Parameterrs
    func setProviderParameter(_ provider: Provider, _ text: String) -> Provider {
        var currentProvider = provider
        if currentProvider.parameter?["q"] != nil {
            currentProvider.parameter?["q"] = text
            
        } else {
            currentProvider.parameter?["query"] = text
        }
        return currentProvider
    }
    
    // MARK: - GetDataFromServer Method
    func fetchData(text: String) {
        for provider in providersList where provider.isOn {
            let currentProvider = setProviderParameter(provider, text)
            DispatchQueue.main.async {
                self.myDispatchGroup.enter()
                ServiceManager.manager.request(provider: currentProvider) { [provider] data, error in
                    if let error = error { print(error) }
                    self.queue.async(flags: .barrier) {
                        self.loadSection(data: data, provider: provider)
                        self.myDispatchGroup.leave()
                    }
                }
            }
        }
        
        myDispatchGroup.notify(queue: DispatchQueue.main) {
            self.didFinishedLoading()
        }
    }
    // MARK: - Handle TextChange
    func handleTextChange(_ text: String) {
        searchWebWorkItem?.cancel()
        if !(photoSections?.isEmpty ?? true) {
            resetDataSouce()
        }
        // MARK: - Implementation DispatchWorkItem
        searchWebWorkItem = DispatchWorkItem {
            self.enableProviders()
            self.fetchData(text: text)
            self.disableProviders()
        }
        guard let searchItem = searchWebWorkItem else { return }
        DispatchQueue.global().asyncAfter(deadline: .now() + 3, execute: searchItem)
    }
}
// MARK: - UITableViewDataSource, UITableViewDelegate
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
    
    // MARK: - didSelectRowAt Implementation
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
    
    // MARK: - cellForRowAt Implementation
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ImageTableViewCell", for: indexPath)
            as? ImageTableViewCell else { fatalError("Unable to deque Tableview with ImageTableViewCell") }
        
        guard let photoDetails = photoSections?[indexPath.section].photos?[indexPath.row] else { fatalError("data not present") }
        
        cell.setProterties(urlStr: photoDetails.imageUrl, providerName: photoDetails.name.rawValue, applyFilter)
        return cell
    }
}

// MARK: - UISearchBarDelegate
extension ImageListViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        resetDataSouce()
        self.view.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else { resetDataSouce(); return }
        print("count: ", searchText.count )
        if searchText.count >= 5 {
            let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            if let stringForURL = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                handleTextChange(stringForURL)
            }
        }
    }
    
}

// MARK: - Perform Add/Remove/ Helper Methods Operation to _photosections
extension ImageListViewController {
    
    func removeProvider(provider: ProviderInfo) {
        self._photoSections.removeAll { $0.name == provider.name }
        tableView.reloadData()
    }
    func addProvider() {
        guard  let text = searchBar.text, text.count >= 5 else { return }
        fetchData(text: text)
    }
    
    func didFinishedLoading() {
        self.showNoResults()
        self.tableView.reloadData()
        print("Reload")
    }
    
    func showNoResults() {
        self.tableView.backgroundView = (numberOfSetions() > 0) ? nil : self.label
    }
    
    func numberOfSetions() -> Int {
        guard let section = self.photoSections else { return 0 }
        return section.count
    }
    
    func enableProviders() {
        for (index, provider) in self.providersInfo.enumerated() where provider.isOn == true {
            self.providersList[index].isOn = true
        }
    }
    
    func disableProviders() {
        for index in 0 ..< self.providersList.count {
            self.providersList[index].isOn = false
        }
    }
    
    func resetDataSouce() {
        _photoSections = []
        self.tableView.reloadData()
    }
}

extension ImageListViewController: SettingViewControllerDelegate {
    
    // MARK: - Apply Filter To  All Images and Reload
    func applyFilterToImages(filter: FilterType) {
        if filter == .none {
            tableView.reloadData()
            applyFilter = nil
        } else {
            applyFilter = filter
            tableView.reloadData()
        }
    }
    // MARK: - SetupAddReveProvider
    func setupAddReveProvider(provider: ProviderInfo) {
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
    // MARK: - Update Providers availability
    func updateProviders(provider: ProviderInfo) -> Int? {
        for (index, currentProvider) in providersInfo.enumerated() where currentProvider.name == provider.name {
            self.providersInfo[index].isOn = provider.isOn
            self.providersList[index].isOn = provider.isOn
            return index
        }
        return nil
    }
}
