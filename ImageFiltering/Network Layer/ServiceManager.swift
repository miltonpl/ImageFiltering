//
//  ServiceManager.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/4/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import Foundation
class ServiceManager {
    
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
                completionHandler(nil, error)
                return
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
}
