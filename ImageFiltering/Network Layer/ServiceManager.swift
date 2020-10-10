//
//  ServiceManager.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/4/20.
//  Copyright © 2020 Milton. All rights reserved.
//
import UIKit
import Foundation
class ServiceManager {
    let imageCache = NSCache<NSString, CIImage >()
    
    static var manager = ServiceManager()
    
    private init () {}
    
    func request(urlString: String, header: [String: String]?, parameters: [String: String]?, completionHandler: @escaping(Any?, Error?) -> Void) {
        
        guard var urlComponents = URLComponents(string: urlString) else { return }
        if let parameters = parameters {
            var elements: [URLQueryItem] = []
            for(key, value) in parameters {
                elements.append(URLQueryItem(name: key, value: value))
            }
            urlComponents.queryItems = elements
        }
        guard let url = urlComponents.url else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let header = header {
            request.allHTTPHeaderFields = header
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error  in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data else {
                completionHandler(nil, error); return
            }
            
            do {
                let dataDictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                completionHandler(dataDictionary, nil)
            } catch {
                
                completionHandler(nil, error)
            }
        }
        task.resume()
    }
    
    private func downloadImage(stringURL: String, completion: @escaping (_ image: CIImage?) -> Void) {
        let keyChache = stringURL as NSString
        if let cashedImage = imageCache.object(forKey: keyChache) {
            completion(cashedImage); return
            
        } else {
            
            if let url = URL(string: stringURL), let ciImage = CIImage(contentsOf: url) {
                imageCache.setObject(ciImage, forKey: keyChache)
                completion(ciImage)
            } else {
                
                completion(nil)
            }
        }
    }
    
    func applyFilter(imageUrl: String, filter: FilterType, completionHandler: @escaping (_ image: UIImage?) -> Void) {
        let filter = CIFilter(name: filter.rawValue)
        
        //download CIImage and apply Filter
        downloadImage(stringURL: imageUrl) { ciInputImage in
            filter?.setValue(ciInputImage, forKey: "inputImage")
            //Get output CIImage, render as CGImage First to retail proper UIImage scale
            let ciOutput = filter?.outputImage
            let ciContext = CIContext()
            
            if let ciOutputImage = ciOutput, let ciOutputExtent = ciOutput?.extent {
                let cgImage = ciContext.createCGImage(ciOutputImage, from: ciOutputExtent)
                if let cgImageSuccesful = cgImage {
                    // convet to UIImage and return image
                    completionHandler(UIImage(cgImage: cgImageSuccesful))
                    
                } else {
                    print("not successful to create CIImage ")
                    completionHandler(nil)
                }
                
            } else {
                print("ERROR unwrapping CIImage and applying CIOutput?.extent")
                completionHandler(nil)
            }
            
        }
    }
    
}
