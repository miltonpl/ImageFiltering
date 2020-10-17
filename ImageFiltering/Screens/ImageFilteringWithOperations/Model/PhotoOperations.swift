//
//  PhotoOperations.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/11/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import UIKit

class ImageDownloader: Operation {
    private var _executing = false
    private var _finished = false
    
    let imageCache = NSCache<NSString, UIImage >()
    var photoRecord: PhotoProtocol
    
    init(_ photoRecord: PhotoProtocol) {
        self.photoRecord = photoRecord
    }
    override var isAsynchronous: Bool {
        return true
    }
    override var isExecuting: Bool {
        get {
            return _executing
        }
        set {
            willChangeValue(forKey: "isExecuting")
            if _executing != newValue {
                _executing = newValue
            }
            didChangeValue(forKey: "isExecuting")
        }
    }
    override var isFinished: Bool {
        get {
            return _finished
        }
        set {
            willChangeValue(forKey: "isFinished")
            if _finished != newValue {
                _finished = newValue
            }
            didChangeValue(forKey: "isFinished")
        }
    }
    private func completionOperation() {
        isFinished = true
        isExecuting = false
        print("OperationFinished in ImageDownloader")
    }
    override func start() {
        if isCancelled {
            isFinished = true
            return
        }
        isExecuting = true
        
        guard let strUrl = photoRecord.imageUrl else { return }
        let keyChache = strUrl as NSString
        if let cashedImage = imageCache.object(forKey: keyChache) {
            
            if isCancelled {
                isFinished = true
                return
            }
            self.photoRecord.state = .downloaded
            self.photoRecord.image = cashedImage
        } else {
            guard let url = URL(string: strUrl) else {
                print("Not valid URL in imagedonwloader "); return }
            do {
                let imageData = try Data(contentsOf: url)
                
                if isCancelled {
                    isFinished = true
                    return
                }
                let image = UIImage(data: imageData)
                self.photoRecord.state = .downloaded
                self.photoRecord.image = image
                if let image = image {
                    self.imageCache.setObject(image, forKey: keyChache)
                }
                
                self.completionOperation()
                
            } catch {
                print(error)
                self.photoRecord.state = .failed
                self.photoRecord.image = UIImage(named: "Failed")
                self.completionOperation()
            }
        }
    }
    override func cancel() {
        super.cancel()
        if isExecuting {
            isExecuting = false
            isFinished = true
        }
    }
}

class ImageFiltration: Operation {
    
    private var _isExecuting = false
    private var _isFinished = false
    
    public var photoRecord: PhotoProtocol
    
    init(_ photoRecord: PhotoProtocol) {
        self.photoRecord = photoRecord
    }
    override var isAsynchronous: Bool {
        return true
    }
    override var isExecuting: Bool {
        get {
            return _isExecuting
        }
        set {
            willChangeValue(forKey: "isExecuting")
            if _isExecuting != newValue {
                _isExecuting = newValue
            }
            didChangeValue(forKey: "isExecuting")
        }
    }
    override var isFinished: Bool {
        get {
            return _isFinished
        }
        set {
            willChangeValue(forKey: "isFinished")
            if _isFinished != newValue {
                _isFinished = newValue
            }
            didChangeValue(forKey: "isFinished")
        }
    }
    override func cancel() {
        super.cancel()
        if isExecuting {
            isExecuting = false
            isFinished = true
        }
    }
    private func completionOperation() {
        isFinished = true
        isExecuting = false
        print("OperationFinished in ImaFiltering")
    }
    
    override func start() {
        if isCancelled {
            isFinished = true
            return
        }
        _isExecuting = true
        guard self.photoRecord.state == .downloaded, let image = photoRecord.image else { return }
        if let strUrl = photoRecord.imageUrl, let filteredImage = applyFilterToPhoto(image, .chrome, strUrl ) {
            photoRecord.image = filteredImage
            photoRecord.state = .filtered
            completionOperation()
        }
        completionOperation()
    }
    
    private func applyFilterToPhoto(_ image: UIImage, _ filter: FilterType, _ strUrl: String) -> UIImage? {
        if filter == .none {
            return image
        }
        guard let data = image.pngData() else { return nil }
        let inputImage = CIImage(data: data)
        if isCancelled {
            self.isFinished = true
            return nil
        }
        guard let filter = CIFilter(name: filter.rawValue) else { return nil }
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        if isCancelled {
            isFinished = true
            return nil
        }
        //Get output CIImage, render as CGImage First to retail proper UIImage scale
        //        let context = CIContext(options: nil)
        let context = Constants.ciContext
        guard let outputImage = filter.outputImage, let outImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        return UIImage(cgImage: outImage)
    }
}

class FetchDataOperation: Operation {
    private let stateLock = NSLock()
    private var _isFinished = false
    private var _isExecuting = false
    private var provider: Provider
    public var contentData: Any?
    
    init(provider: Provider) {
        self.provider = provider
    }
    override var isAsynchronous: Bool {
        return true
    }
    override var isExecuting: Bool {
        get {
            return _isExecuting
        }
        set {
            willChangeValue(forKey: "isExecuting")
            if _isExecuting != newValue {
                _isExecuting = newValue
            }
            didChangeValue(forKey: "isExecuting")
        }
    }
    override var isFinished: Bool {
        get {
            return _isFinished
        }
        set {
            willChangeValue(forKey: "isFinished")
            if _isFinished != newValue {
                _isFinished = newValue
            }
            didChangeValue(forKey: "isFinished")
        }
    }
    private func completionOperation() {
        isFinished = true
        isExecuting = false
        print("OperationFinished in FetchDataOperation")
    }
    override func cancel() {
        super.cancel()
        if isExecuting {
            self.isExecuting = false
            self.isFinished = true
        }
    }
    override func start() {
        if isCancelled {
            self.isFinished = true
            return
        }
        ServiceManager.manager.request(provider: self.provider) { data, error in
            if  let error  = error {
                print(error as Error)
            }
            if self.isCancelled {
                self.isFinished = true
                return
            }
            self.contentData = data
            self.completionOperation()
        }
    }
}
