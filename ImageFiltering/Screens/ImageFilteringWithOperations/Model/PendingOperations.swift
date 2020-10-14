//
//  PendingOperations.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/11/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import Foundation

class PendingOperation {
    
    var downloadsInProgress: [IndexPath: Operation] = [:]
    
    lazy var downloadQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "Download queue"
//        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    var filtrationsInProgress: [IndexPath: Operation] = [:]
    lazy var filterationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "Image Filteration queue"
//        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    var dataFetchInProgress: [IndexPath: Operation] = [:]
    lazy var dataFetchQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "Data Fetch queue"
//        queue.maxConcurrentOperationCount = 1
        return queue
    }()
}
