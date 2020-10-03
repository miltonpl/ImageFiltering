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
    let ThreeSecondsDelay: DispatchTimeInterval = .seconds(3)
    var searchWebWorkItem: DispatchWorkItem?
    private var queue = DispatchQueue.init(label: "mydata.queue", attributes: .concurrent)
    
    var urls: [String] = []
    var imageList: [ImageInfo] = []
    var storedDataResponse: [APIResponse] = []
    var imageDataAPI: [APIResponse]? {
        queue.sync {
            return storedDataResponse
            }
        }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(ImageTableViewCell.nib(), forCellReuseIdentifier: ImageTableViewCell.identifier)

        searchBar.delegate = self
        self.title = "Images"
//        fetchData()
    }
    
    //MARK: - getDataFromServer Method
    func fetchData(item: String) {
        queue.sync {
            storedDataResponse = []
        }
        imageList = []
        urls = [Source.url1 + item, Source.url2 + item, Source.url3+item]
        print(item)
        print(urls)
            let myGroup = DispatchGroup()
            
            for current in urls {
                guard let urlString = current.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                    let url = URL(string: urlString) else {continue}
                print("pass URL()")
                myGroup.enter()
                DispatchQueue.global().async {
                    
                    do {
                        let data = try Data(contentsOf: url)
                        let responseObj = try JSONDecoder().decode(APIResponse.self, from: data)
                        
                        self.queue.async(flags: .barrier, execute:{
                            self.storedDataResponse.append(responseObj)
                        } )
                        myGroup.leave()
                    }
                    catch {
                        print(error)
                        myGroup.leave()
                    }
                }//end of global().async
            }
            myGroup.notify(queue: DispatchQueue.main) {
                
                guard let imageSource = self.imageDataAPI?.first, let imageFile = imageSource.image else {return}
                print(imageFile.count)

                for image in imageFile {
                    self.imageList.append(image)
                    guard let url = image.imageUrl else {continue}
                    print(url)
                }
                self.tableView.reloadData()
                
            }
        }
    
    
    func handleTextChange(_ text: String) {
        searchWebWorkItem?.cancel()
        
        searchWebWorkItem = DispatchWorkItem {
            self.fetchData(item: text)
        }
        guard let searchItem = searchWebWorkItem else {return }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + ThreeSecondsDelay, execute: searchItem)
    }
        
        
    
}

extension ImageListViewController: UITableViewDelegate {
    
    
}

extension ImageListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImageTableViewCell.identifier, for: indexPath) as? ImageTableViewCell else {fatalError("Unable to deque Tableview with ImageTableViewCell")}
        
        let image = imageList[indexPath.row]
        cell.setProterties(item: image, title: textEntered ?? "" )
        return cell
    }
    
    
    
}

extension ImageListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarSearchButtonClicked")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let searchResultVC = storyboard.instantiateViewController(identifier: "SearchResultViewController") as? SearchResultViewController else  {fatalError("unable to to find view Controller")}
        searchResultVC.imageData = imageDataAPI
        
        self.navigationController?.pushViewController(searchResultVC, animated: true)
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
   
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        if searchText.count >= 5 {
            print("text: ", searchText)
            textEntered = searchText
            handleTextChange(searchText)
        }
    } // called when text changes (including clear)

    
}
