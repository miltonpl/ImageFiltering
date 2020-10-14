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
            self.tableView.keyboardDismissMode = .onDrag
            self.tableView.tableFooterView = UIView()
            self.tableView.rowHeight = 300
            self.tableView.register(PhotoSearchTableViewCell.nib(), forCellReuseIdentifier: PhotoSearchTableViewCell.identifier)
        }
    }
    @IBOutlet private weak var searchBar: UISearchBar! {
        didSet {
            self.searchBar.delegate = self
            self.searchBar.placeholder = "Search Image"
            self.searchBar.showsCancelButton = true
        }
    }
    lazy var label: UILabel = {
        let label = UILabel()
        label.text = "Search any images and \nsaved in your fivotire collection"
        label.font = .boldSystemFont(ofSize: 20.0)
        label.textColor = .systemBackground
        return label
        
    }()
    private var reloadDataQueue = DispatchQueue(label: "reload.data.queue")
    private let pendingOperations = PendingOperation()
    private var helper = Helper()
    private var timer: Timer?
    private var filterType: FilterType?
    private var providersList: [Provider] = []
    private var providersInfo: [ProviderInfo] = []
    private var _photoSections: [PhotoSection] = []
    private var photoSections: [PhotoSection]? {
        get {
            self.reloadDataQueue.sync( execute: {
                return self._photoSections
            })
        } set {
            self.reloadDataQueue.async( flags: .barrier, execute: {
                self._photoSections = newValue ?? []
                
            })
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Screen Using Operations"
        self.setupSettingButton()
        self.providersList = helper.providersList
        self.providersInfo = helper.providersInfo
        self.showNoResults()
        self.tableView.backgroundView = self.label
    }
    
    func showNoResults() {
        self.tableView.backgroundView = (numberOfSetions() > 0) ? nil : self.label
    }
    func didFinishloading() {
        showNoResults()
        tableView.reloadData()
    }
    
    func numberOfSetions() -> Int {
        guard let section = self.photoSections else { return 0 }
        return section.count
    }
    
    func numberOfRows(in section: Int) -> Int {
        guard let photoSection = self.photoSections?[section] else { return 0 }
        return photoSection.photos?.count ?? 0
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
    func setProviderParameter(_ provider: Provider, _ text: String) -> Provider {
        var currentProvider = provider
        if currentProvider.parameter?["q"] != nil {
            currentProvider.parameter?["q"] = text
            
        } else {
            currentProvider.parameter?["query"] = text
        }
        return currentProvider
    }
    
    func handleTextChange(_ text: String) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false, block: { _ in
            self.resetDataSouce()
            self.enableProvider()
            self.fetchData(text: text)
            self.disableProvider()
        })
    }
    func resetDataSouce() {
        _photoSections = []
    }
    func enableProvider () {
        for (index, provider) in self.providersInfo.enumerated() where provider.isOn == true {
            self.providersList[index].isOn = true
        }
    }
    func disableProvider () {
        for index in 0 ..< self.providersList.count {
            self.providersList[index].isOn = false
        }
    }
}

extension PhotoListViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        resetDataSouce()
        self.view.endEditing(true)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else { resetDataSouce(); return }
        if searchText.count >= 5 {
            let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            if let stringForURL = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                print("searchBar: ", text)
                handleTextChange(stringForURL)
            }
        }
    }
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
    
    func reloadDataTableview() {
        print("Reload Data fo Sections: ", self.photoSections?.count ?? 0)
        self.tableView.reloadData()
        self.photoSections?.forEach({ (section) in
            print(section.name, section.photos?.count ?? 0)
        })
    }
    func fetchData(text: String) {
        let complitionOperation = BlockOperation(block: reloadDataTableview)
        for provider in providersList where provider.isOn {
            let currentProvider = setProviderParameter(provider, text)
            let fetchDataOperation = FetchDataOperation(provider: currentProvider)
            complitionOperation.addDependency(fetchDataOperation)
            pendingOperations.dataFetchQueue.addOperation(fetchDataOperation)
            fetchDataOperation.completionBlock = {
                if fetchDataOperation.isCancelled {
                    return
                }
                print("cuncurrentent Finished")
                guard let photosList = fetchDataOperation.contentData else { return }
                self.loadSection(data: photosList, provider: provider)
            }
        }
        OperationQueue.main.addOperation(complitionOperation)
//        pendingOperations.dataFetchQueue.addOperation(complitionOperation)
    }
    func startDownload(for photoRecord: PhotoProtocol, at indexPath: IndexPath) {
        guard self.pendingOperations.downloadsInProgress[indexPath] == nil else { return }
        let downloaderOperation = ImageDownloader(photoRecord)
        
        downloaderOperation.completionBlock = {
            if downloaderOperation.isCancelled {
                return
            }
            OperationQueue.main.addOperation {
//                OperationQueue.current?.addBarrierBlock {
                    self.photoSections?[indexPath.section].photos?[indexPath.row] = downloaderOperation.photoRecord
                        self.tableView.reloadData()
                    self.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
//                self.tableView.reloadRows(at: [indexPath], with: .automatic)

//                }
            }
        }
        self.pendingOperations.downloadsInProgress[indexPath] = downloaderOperation
        self.pendingOperations.downloadQueue.addOperation(downloaderOperation)
    }
    
    func startFiltration(for photoRecord: PhotoProtocol, at indexPath: IndexPath ) {
        guard self.pendingOperations.filtrationsInProgress[indexPath] == nil else { return }
        
        let filterOperation = ImageFiltration(photoRecord)
        filterOperation.completionBlock = {
            if filterOperation.isCancelled { return }
            OperationQueue.main.addOperation {
//                OperationQueue.current?.addBarrierBlock {
                    self.photoSections?[indexPath.section].photos?[indexPath.row] = filterOperation.photoRecord
                    self.pendingOperations.filtrationsInProgress.removeValue(forKey: indexPath)
//                self.tableView.reloadRows(at: [indexPath], with: .automatic)
                      self.tableView.reloadData()
//                }
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
        case .filtered:
            print("Already filterd")
        case .failed:
            print("Fail")
        }
    }
}
extension PhotoListViewController: SettingViewControllerDelegate {
    
    func applyFilterToImages(filter: FilterType) {
        filterType = (filter != .none) ? filter : nil
    }
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
        
        let navController = UINavigationController(rootViewController: filterViewController)
        self.navigationController?.present(navController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoSearchTableViewCell", for: indexPath) as?
            PhotoSearchTableViewCell,
            var photoDetails = photoSections?[indexPath.section].photos?[indexPath.row] else {
                fatalError("unable to dequeue table view cell withIdentifier: PhotoListTableViewCell or photoDetails from photoSection!" ) }
        
        photoDetails.filter = .mono
        cell.setProterties(photoDetails: photoDetails)
        switch photoDetails.state {
        case .new, .downloaded:
            //            if !tableView.isDragging && !tableView.isDecelerating {
            startOperations(for: photoDetails, at: indexPath)
            //            }
            
        default:
            print("filtered ")
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

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        loadingForOnscreenCells()
        resumeAllOperations()
    }
}
