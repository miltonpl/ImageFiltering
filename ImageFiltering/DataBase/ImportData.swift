//
//  ImportData.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/12/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import UIKit
class ImportData {
    let fileName = "DataUrl.txt"
    let strUrl: String
    var dataOutput: Any?
    init(strUrl: String) {
        self.strUrl = strUrl
    }
    func saveInDataBase() {
        if let dir = FileManager.default.urls(for: .documentationDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(fileName)
            print(fileURL, "In data")
            //writing
            do {
                try strUrl.write(to: fileURL, atomically: false, encoding: .utf8)
                
            } catch {
                print(error)
            }
            //reading
            do {
                let text2 = try String(contentsOf: fileURL, encoding: .utf8)
                dataOutput = text2
            } catch {
                print(error)
            }
        }
    }
}
