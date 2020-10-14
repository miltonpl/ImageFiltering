//
//  UIImageViewExtension.swift
//  ImageFiltering
//
//  Created by Milton Palaguachi on 10/13/20.
//  Copyright © 2020 Milton. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func downloadImage(with url: URL) {
        DispatchQueue.global().async {
            do {
                let data = try Data(contentsOf: url)
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    self.image = image
                }
            } catch {
                print(error)
                DispatchQueue.main.async {
                    self.image = Constants.failedImage
                }
            }
        }
    }
    
    func downloadAndApplyFilterToImage(_ url: URL, _ filter: FilterType) {
        DispatchQueue.global().async {
            let inputImage = CIImage(contentsOf: url)
            guard let filter = CIFilter(name: filter.rawValue) else {
                DispatchQueue.main.async {
                    self.image = Constants.failedImage
                }
                return
            }
            filter.setValue(inputImage, forKey: kCIInputImageKey)
            let context = Constants.ciContext
            
            guard let outputImage = filter.outputImage,
                let outImage = context.createCGImage(outputImage, from: outputImage.extent) else {
                    DispatchQueue.main.async {
                        self.image = Constants.failedImage
                    }
                    return }
            
            DispatchQueue.main.async {
                self.image = UIImage(cgImage: outImage)
            }
        }
    }
    func applyFilterToImage(_ image: UIImage, _ filter: FilterType) {
        if filter == .none {
            self.image = image
        }
        DispatchQueue.global().async {
            
            guard let data = image.pngData() else {
                DispatchQueue.main.async {
                    self.image = Constants.failedImage
                }
                return
            }
            let inputImage = CIImage(data: data)
            
            guard let filter = CIFilter(name: filter.rawValue) else {
                DispatchQueue.main.async {
                    self.image = Constants.failedImage
                }
                return
            }
            filter.setValue(inputImage, forKey: kCIInputImageKey)
            let context = Constants.ciContext
            guard let outputImage = filter.outputImage, let outImage = context.createCGImage(outputImage, from: outputImage.extent) else {
                DispatchQueue.main.async {
                    self.image = Constants.failedImage
                }
                return
            }
            
            DispatchQueue.main.async {
                self.image = UIImage(cgImage: outImage)
            }
        }
    }
}
