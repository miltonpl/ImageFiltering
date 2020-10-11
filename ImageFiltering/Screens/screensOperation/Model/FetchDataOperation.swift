//
//  FetchDataOperation.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/11/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import UIKit
import Foundation

/*
 overrite two function
 -start
 -main
 */
//Note -> Related to Operation Queue
/*
 you can suspend the Queue
 you can resume the Queue
 you can pass the Que opperation
 */
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
//            print("In FetchOperation Class: ", data ?? "NO DATA from Service Managarer in FetOpeation Class ")
            self.completionBlock?()
        }
        
    }
    //This methos Should be used.
    /*
     
     override var isAsynchronous: Bool {
     true
     }
     override var isExecuting: Bool
     override var  override var isFinished: Bool
     
     */
    
    /*
     override func main() {
     if isCancelled {
     return
     }
     do {
     let data = try  Data(contentsOf: self.url)
     if isCancelled {
     return
     }
     
     self.contentData = data
     
     } catch {
     print(error)
     return
     }
     }
     */
}
