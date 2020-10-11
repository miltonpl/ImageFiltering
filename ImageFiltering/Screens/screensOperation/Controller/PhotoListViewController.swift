//
//  PhotoListViewController.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/11/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import UIKit

class PhotoListViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            self.tableView.tableFooterView = UIView()
            self.tableView.register(PhotoSearchTableViewCell.nib(), forCellReuseIdentifier: PhotoSearchTableViewCell.identifier)
        }
    }
    @IBOutlet private weak var searchBar: UISearchBar!
    private var reloadDataQueue = DispatchQueue(label: "reload.data.queue")
    
    private var applyFilter: FilterType?
    private var providersList: [Provider] = []
    private var providersInfo: [ProviderInfo] = []
    private let pendingOperations = PendingOperation()
    
    private var _photoSections: [PhotoSection] = []
    private var photoSections: [PhotoSection]? {
        
        get {
            self.reloadDataQueue.sync( flags: .barrier, execute: {
                return self._photoSections
            })
        }
        set {
            _photoSections = newValue ?? []
            
        }
    }
    let operationQueue = OperationQueue()
    var timer = Timer()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Operation Screen"
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
        
        settingViewController.configure(providers: providersInfo)
        settingViewController.delegate = self
        let navController = UINavigationController(rootViewController: settingViewController)
        self.navigationController?.present(navController, animated: true, completion: nil)
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
    @objc func fetchData(text: String) {
        
        for provider in providersList where provider.isOn {
            print(provider)
            
            var parameters = provider.parameter
            if provider.parameter["q"] != nil {
                parameters["q"] = text
            } else {
                parameters["query"] = text
            }
            let downloaderDataOperation = FetchDataOperation(urlString: provider.url, header: provider.header, parameters: parameters)
            
            operationQueue.addOperation(downloaderDataOperation)
            downloaderDataOperation.completionBlock = {
                if downloaderDataOperation.isCancelled {
                    return
                }
                
                print("Completion Block")
                guard let photosList = downloaderDataOperation.contentData else { return }
                OperationQueue.main.addBarrierBlock {
                    self.loadSection(data: photosList, provider: provider)
                }
                OperationQueue.main.addOperation {
                    self.tableView.reloadData()
                    print("Reloading tableView in Opeation.main.addOperation")
                    if let dataPhotos = self.photoSections {
                        print(dataPhotos.count)
                        dataPhotos.forEach { print("sections: ", $0.name, "count: ", $0.photos?.count ?? 0) }
                    }
                }
                
            }
            
        }
        
    }
    
    func handleTextChange(_ text: String) {
        timer.invalidate()
        //        queue.isSuspended = true
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(timerAction(timer:)), userInfo: ["text": text], repeats: false)
    }
    // called every time interval from the timer
    @objc func timerAction(timer: Timer) {
        print("Timer: After 3 seconds")
        guard let context = timer.userInfo as? [String: String] else { return }
        let text = context["text", default: "Anotymous"]
        print("After Timer: ", text)
        
        if !(photoSections?.isEmpty ?? true) {
            _photoSections = []
        }
        
        print(self.providersInfo.count)
        for (index, provider) in self.providersInfo.enumerated() where provider.isOn == true {
            self.providersList[index].isOn = true
        }
        
        self.fetchData(text: text)
        for index in 0 ..< self.providersList.count {
            self.providersList[index].isOn = false
        }
    }
}

extension PhotoListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count >= 5 {
            let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            if let stringForURL = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                print("searchBar: ", text)
                handleTextChange(stringForURL)
            }
        }
    } // called when text changes (including clear)
}
extension PhotoListViewController {
    
    func removeProvider(provider: ProviderInfo) {
        self._photoSections.removeAll { $0.name == provider.name }
        tableView.reloadData()
    }
    
    func addProvider() {
        guard  let text = searchBar.text, text.count >= 5 else { return }
        fetchData(text: text)
    }
    
    func startDownload(for photoRecord: PhotoProtocol, at indexPath: IndexPath) {
        guard self.pendingOperations.downloadsInProgress[indexPath] == nil else { return }
        let downlaoderOperation = ImageDownloader(photoRecord)
        
        downlaoderOperation.completionBlock = {
            
            if downlaoderOperation.isCancelled {
                return
            }
            OperationQueue.main.addOperation {
                self.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
                self.photoSections?[indexPath.section].photos?[indexPath.row] = downlaoderOperation.photoRecord
                self.tableView.reloadData()
            }
        }
        self.pendingOperations.downloadsInProgress[indexPath] = downlaoderOperation
        self.pendingOperations.downloadQueue.addOperation(downlaoderOperation)
    }
    
    func startFiltration(for photoRecord: PhotoProtocol, at indexPath: IndexPath ) {
        guard self.pendingOperations.filtrationsInProgress[indexPath] == nil else { return }
        
        let filterOperation = ImageFiltration(photoRecord)
        filterOperation.completionBlock = {
            if filterOperation.isCancelled {
                return
            }
            
            OperationQueue.main.addOperation {
                
                self.photoSections?[indexPath.section].photos?[indexPath.row] = filterOperation.photoRecord
                self.pendingOperations.filtrationsInProgress.removeValue(forKey: indexPath)
                self.tableView.reloadData()
                
                //                self.tableView.reloadRows(at: [indexPath], with: .fade)
                print(indexPath, "Filter\n", filterOperation.photoRecord.image ?? "None")
                
            }
        }
        pendingOperations.filtrationsInProgress[indexPath] = filterOperation
        pendingOperations.filterationQueue.addOperation(filterOperation)
        
    }
    
    func startOperations(for photoRecord: PhotoProtocol, at indexPath: IndexPath) {
        switch photoRecord.state {
        case .new:
            startDownload(for: photoRecord, at: indexPath)
        case .downloaded:
            startFiltration(for: photoRecord, at: indexPath)
        default:
            print("do nothing")
        }
    }
}

extension PhotoListViewController: SettingViewControllerDelegate {
    
    func applyFilterToImages(filter: FilterType) {
        applyFilter = (filter != .none) ? filter : nil
    }
    
    /// Adds Removes Provider to photoSection array
    /// - Parameter provider: API provider
    func updateProvidersList(provider: ProviderInfo) {
        
        let indexProvider = updateProvidersInfo(provider: provider)
        if provider.isOn {
            if let index = indexProvider {
                addProvider()
                providersList[index].isOn = false
            }
            
        } else {
            removeProvider(provider: provider)
        }
    }
    
    func updateProvidersInfo(provider: ProviderInfo) -> Int? {
        for (index, currentProvider) in providersInfo.enumerated() where currentProvider.name == provider.name {
            self.providersInfo[index].isOn = provider.isOn
            self.providersList[index].isOn = provider.isOn
            return index
        }
        return nil
    }
}

extension PhotoListViewController: UITableViewDataSource, UITableViewDelegate {
    
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
            let urlStr = photoSections?[indexPath.section].photos?[indexPath.row].imageUrl, let name = photoSections?[indexPath.section].photos?[indexPath.row].name else {
                fatalError("Unable to instantiate vie controllerr with identity: FilterPhotoViewController") }
        filterViewController.configure(imageStringUrl: urlStr, name: name.rawValue)
        self.navigationController?.pushViewController(filterViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoSearchTableViewCell", for: indexPath) as?
            PhotoSearchTableViewCell,
            var photoDetails = photoSections?[indexPath.section].photos?[indexPath.row] else {
                fatalError("unable to dequeue table view cell withIdentifier: PhotoListTableViewCell or photoDetails from photoSection!" ) }
        
        print("indexPath in cellForRowAt: ", indexPath)
        photoDetails.filter = .mono
        cell.setProterties(photoDetails: photoDetails)
        switch photoDetails.state {
        case .new, .downloaded:
            if !tableView.isDragging && !tableView.isDecelerating {
                startOperations(for: photoDetails, at: indexPath)
            }
            
        default:
            print("not a photo state")
        }
        
        return cell
    }
    func loadingForOnscreenCells() {
        if let pathArray = tableView.indexPathsForVisibleRows {
            var allPendingOperations = Set(pendingOperations.downloadsInProgress.keys)
            allPendingOperations.formUnion(pendingOperations.filtrationsInProgress.keys)
            
            var toBeCancelled = allPendingOperations
            let visiblePaths = Set(pathArray)
            toBeCancelled.subtract(visiblePaths)
            
            var toBeStarted = visiblePaths
            toBeStarted.subtract(allPendingOperations)
            
            for indexPath in toBeCancelled {
                if let pendingDownload = pendingOperations.downloadsInProgress[indexPath] {
                    pendingDownload.cancel()
                }
                pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
                
                if let pendingFiltration = pendingOperations.filtrationsInProgress[indexPath] {
                    pendingFiltration.cancel()
                }
                pendingOperations.filtrationsInProgress.removeValue(forKey: indexPath)
            }
            for indexPath in toBeStarted {
                if let recordToProcess = photoSections?[indexPath.section].photos?[indexPath.row] {
                    startOperations(for: recordToProcess, at: indexPath)
                }
            }
        }
        
    }
    
    func resumeAllOperations() {
        pendingOperations.downloadQueue.isSuspended = false
        pendingOperations.filterationQueue.isSuspended = false
    }
    func suspendAllOperations() {
        pendingOperations.downloadQueue.isSuspended = true
        pendingOperations.filterationQueue.isSuspended = true
        
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        suspendAllOperations()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            loadingForOnscreenCells()
            resumeAllOperations()
        }
    }
    
    // called when scroll view grinds to a halt
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        loadingForOnscreenCells()
        resumeAllOperations()
    }
    
}
