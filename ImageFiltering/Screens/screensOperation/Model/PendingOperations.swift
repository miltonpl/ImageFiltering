//
//  PendingOperations.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/11/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import Foundation

class PendingOperation {
    
    lazy var downloadsInProgress: [IndexPath: Operation] = [:]
    lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download queue"
//        queue.maxConcurrentOperationCount = 2
        return queue
    }()
    
    lazy var filtrationsInProgress: [IndexPath: Operation] = [:]
    lazy var filterationQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Image Filteration queue"
//        queue.maxConcurrentOperationCount = 2
        return queue
    }()
}
