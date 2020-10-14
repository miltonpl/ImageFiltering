//
//  FetchDataOperation.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/11/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import UIKit

class FetchDataOperation: Operation {
    var urlString: String = ""
    let header: [String: String]?
    let parameters: [String: String]?
    var contentData: Any?
    
    init(urlString: String, header: [String: String]? = nil, parameters: [String: String]? = nil) {
        self.urlString = urlString
        self.header = header
        self.parameters = parameters
    }
    override func start() {
        if isCancelled {
            return
        }
        ServiceManager.manager.request(urlString: self.urlString, header: header, parameters: parameters) { data, error in
            if  let error  = error {
                print(error as Error)
            }
            if self.isCancelled {
                return
            }
            self.contentData = data
            self.completionBlock?()
        }
    }
}
