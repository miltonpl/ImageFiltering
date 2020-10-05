//
//  ViewController.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/2/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import UIKit

class ImageListViewController: UIViewController {
    @IBOutlet private weak var tableView:UITableView! {
        didSet {
            self.tableView.tableFooterView = UIView()
        }
    }
    @IBOutlet private weak var searchBar:UISearchBar!
    var textEntered:String?
    let myGroupForJosonDecoder = DispatchGroup()
    let ThreeSecondsDelay: DispatchTimeInterval = .seconds(3)
    var searchWebWorkItem: DispatchWorkItem?
    var queue = DispatchQueue.init(label: "mydata.queue", attributes: .concurrent)
    var collectionList: [PhotoDescription] = []
    var urls: [Source] = [.splashbase,.pixabay, .pexels]
    var imageDict: [Section: [PhotoDescription]] = [:]
    var storedDataResponse: [ResponseProtocol] = []
    var imageDataAPI: [ResponseProtocol]? {
        queue.sync {
            return storedDataResponse
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.observerAddNotification()
        tableView.register(ImageTableViewCell.nib(), forCellReuseIdentifier: ImageTableViewCell.identifier)
        searchBar.delegate = self
        self.title = "My Photo Collection"
    }
    
    //MARK: - getDataFromServer Method
    func fetchData(item: String) {
        for urlSource in urls {
            let addItemToUrl = urlSource.rawValue + item
            guard let urlStr = addItemToUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                let url = URL(string: urlStr)  else {continue}
            let request = NSMutableURLRequest(url: url , cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
            
            switch urlSource {
            case .splashbase:
                request.httpMethod = "GET"
                ServiceManager.manager.request(url: request) { data, error in
                    
                    guard let dataObj = data as? Data else { return }
                    self.myGroupForJosonDecoder.enter()
                    DispatchQueue.global().async {
                        
                        do {
                            let responseObj = try JSONDecoder().decode(Splashbase.self, from: dataObj )
                            self.queue.async(flags: .barrier) {
                                self.storedDataResponse.append(responseObj)
                                self.myGroupForJosonDecoder.leave()
                            }
                        }
                        catch {
                            print(error)
                            self.myGroupForJosonDecoder.leave()
                        }
                    }
                }
                break
            case .pixabay:
                request.httpMethod = "GET"
                ServiceManager.manager.request(url: request) { data, error in
                    guard let dataObj = data as? Data else { return}
                    self.myGroupForJosonDecoder.enter()
                    DispatchQueue.global().async {
                        do {
                            
                            let responseObj = try JSONDecoder().decode(PixaBay.self, from: dataObj)
                            self.queue.async(flags: .barrier) {
                                self.storedDataResponse.append(responseObj)
                                self.myGroupForJosonDecoder.leave()
                            }
                        }
                        catch {
                            print(error)
                            self.myGroupForJosonDecoder.leave()
                        }
                    }
                }
                break
            case .pexels:
                request.allHTTPHeaderFields = Constants.headers3
                request.httpMethod = "GET"
                ServiceManager.manager.request(url: request) { data, error in
                    guard let dataObj = data as? Data else { return }
                    self.myGroupForJosonDecoder.enter()
                    DispatchQueue.global().async {
                        do {
                            let responseObj = try JSONDecoder().decode(Pexels.self, from: dataObj )
                            self.queue.async(flags: .barrier) {
                                self.storedDataResponse.append(responseObj)
                                self.myGroupForJosonDecoder.leave()
                            }
                        }
                        catch {
                            print(error)
                            self.myGroupForJosonDecoder.leave()
                        }
                    }
                }
                break
            }
        }//end forloop
        self.myGroupForJosonDecoder.notify(queue: DispatchQueue.main) {
            print("notify")
            self.tableView.reloadData()
        }
    }
    
    func handleTextChange(_ text: String) {
        searchWebWorkItem?.cancel()
        searchWebWorkItem = DispatchWorkItem {
            self.storedDataResponse.removeAll()
            self.fetchData(item: text)
        }
        guard let searchItem = searchWebWorkItem else {return }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + ThreeSecondsDelay, execute: searchItem)
    }
}

extension ImageListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        collectionList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImageTableViewCell.identifier, for: indexPath) as? ImageTableViewCell else {fatalError("Unable to deque Tableview with ImageTableViewCell")}
        let photoInfo = collectionList[indexPath.row]
        cell.setProterties(item: photoInfo)
        return cell
    }
}

extension ImageListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarSearchButtonClicked")
        guard let text = searchBar.text, text.count >= 5 else {return}
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let searchResultVC = storyboard.instantiateViewController(identifier: "SearchResultViewController") as? SearchResultViewController else  {fatalError("unable to to find view Controller")}
        
        if let dataAPI = imageDataAPI {
            for item in dataAPI {
                switch item {
                case is Splashbase:
                    guard  let tp = item as? Splashbase, let list =  tp.image, !list.isEmpty else {
                        print("image list is empty")
                        continue
                    }
                    break
                case is Pexels:
                    guard  let tp = item as? Pexels, let list =  tp.photos, !list.isEmpty else {
                        print("image list is empty")
                        continue
                    }
                    break
                case is PixaBay:
                    guard  let tp = item as? PixaBay, let list =  tp.photos, !list.isEmpty else {
                        print("image list is empty")
                        continue
                    }
                    break
                default:
                    break
                }
            }
            searchResultVC.imageData = self.imageDataAPI
            self.navigationController?.pushViewController(searchResultVC, animated: true)
//            print("back\n\n\n",searchBar.text)
            if let text = searchBar.text, text.count >= 5 {
                storedDataResponse.removeAll()
                fetchData(item: text)
                
            }
            
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        if searchText.count >= 5 {
            print("text: ", searchText)
            textEntered = searchText
            handleTextChange(searchText)
        }
    } // called when text changes (including clear)
}
extension ImageListViewController {
    
    func observerAddNotification() {
           NotificationCenter.default.addObserver(self, selector: #selector(getNotification), name: .myNotificationAdd, object: nil)
       }
    //add photo to collection list
   @objc func getNotification(_ notification: Notification) {
       guard let photo = notification.userInfo?["Add"] as? PhotoDescription else {return }
       collectionList.append(photo)
       tableView.reloadData()
   }
}
