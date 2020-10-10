//
//  OrderOperation.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/8/20.
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
class FetchOperation: Operation {
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

/*
class NetworkManager {
    
    // MARK: - Variables
    
    static let shared = NetworkManager()
    private let cache = NSCache<NSString, CIImage>()
    
    // MARK: - Init
    
    private init() { }
    
  
    
    func downloadFilterImage(with imageUrl: String, filter: FilterType, completed: @escaping (UIImage?) -> Void) {
        
        self.downloadImage(with: imageUrl) { image in
            if let originalCIImage = image {
                var newImage = UIImage(ciImage: originalCIImage)
                
                switch filter {
                case .chrome:
                    break
                    
                case .fade:
                    if let ciImage = self.setFilter(originalCIImage, filterType: CIFilterType.blackWhite) {
                        newImage = UIImage(ciImage: ciImage)
                    }
                    
                case .mono:
                    if let ciImage = self.setFilter(originalCIImage, filterType: CIFilterType.sepia) {
                        newImage = UIImage(ciImage: ciImage)
                    }
                    
                case .noir:
                    if let ciImage = self.setFilter(originalCIImage, filterType: CIFilterType.bloom),
                       let cgOutputImage = CIContext().createCGImage(ciImage, from: originalCIImage.extent) {
                        newImage = UIImage(cgImage: cgOutputImage)
                    }
                case .instant:
                    <#code#>
                case .process:
                    <#code#>
                case .tonal:
                    <#code#>
                case .transfer:
                    <#code#>
                }
                completed(newImage)
                return
            } else {
                completed(nil)
                return
            }
        }
    }
    
    // MARK: - Private Helpers
    
    private func downloadImage(with imageUrl: String, completed: @escaping (CIImage?) -> Void) {
        
        let cacheKey = NSString(string: imageUrl)
        
        if let image = cache.object(forKey: cacheKey) {
            completed(image)
            return
        }
        
        DispatchQueue.global().async {
            if let url = URL(string: imageUrl),
                let image = CIImage(contentsOf: url) {
                completed(image)
                return
            } else {
                completed(nil)
                return
            }
        }
    }
    
    private func setFilter(_ input: CIImage, filterType: CIFilterType) -> CIImage? {
        
        let filter = CIFilter(name: filterType.rawValue)
        filter?.setValue(input, forKey: kCIInputImageKey)
        
        switch filterType {
        case .blackWhite:
            filter?.setValue(0.0, forKey: kCIInputSaturationKey)
            filter?.setValue(0.9, forKey: kCIInputContrastKey)
            
        case .sepia, .bloom:
            filter?.setValue(1.0, forKey: kCIInputIntensityKey)
        }
        return filter?.outputImage
    }
}
*/
