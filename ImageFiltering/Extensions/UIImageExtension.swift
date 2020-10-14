//
//  UIImageExtension.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/13/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import UIKit
extension UIImage {
    func applyFilter(filter: FilterType ) -> UIImage? {
        let filter = CIFilter(name: filter.rawValue)
        //convert UIImage to CIImage and set as input
        let ciInput = CIImage(image: self)
        filter?.setValue(ciInput, forKey: "inputImage")
        //get output CIImage, render as CGImage First to retail proper UIImage scale
        let ciOutput = filter?.outputImage
        let ciContext = CIContext()
        guard let ciOutputImage = ciOutput, let ciOutputExtent = ciOutput?.extent
            else {
                print("ciOutput error ")
                return nil
        }
        let cgImage = ciContext.createCGImage(ciOutputImage, from: ciOutputExtent)
        guard let cgImageSuccesful = cgImage else {
            print("cgImage error ")
            return nil
        }
        return UIImage(cgImage: cgImageSuccesful)
    }
}
