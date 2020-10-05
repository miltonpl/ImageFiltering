//
//  ServiceManager.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/4/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import Foundation
class ServiceManager {
    var queueService = DispatchQueue.init(label: "mydata.queue.service", attributes: .concurrent)

    static var manager = ServiceManager()
    private init() {}
    
    func request(url: NSMutableURLRequest, completionHandler: @escaping(Any?, Error?) -> Void) {
        let myGroup = DispatchGroup()
        myGroup.enter()
        DispatchQueue.global().async {
            let task = URLSession.shared.dataTask(with: url as URLRequest) { data, response, error  in
                guard let httpResponse = response as? HTTPURLResponse,
                    httpResponse.statusCode == 200, let data = data else {
                        self.queueService.async(flags: .barrier) {
                            completionHandler(nil, error)
                        }
                        myGroup.leave()
                    return
                }
                self.queueService.async(flags: .barrier) {
                    completionHandler(data, nil)
                }
                myGroup.leave()
                
            }
            task.resume()
        }
    }
}
