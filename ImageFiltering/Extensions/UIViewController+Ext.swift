// extension UIViewController+Ext.swift
//  Created by Milton Palaguachi on 10/3/20.
//  Copyright © 2020 Milton. All rights reserved.
//
import UIKit
private var aView: UIView?

extension UIViewController {
    func showSpinner() {
        aView = UIView(frame: self.view.bounds)
        //        aView?.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0.8, alpha: 0.2)
        if #available(iOS 13.0, *) {
            aView?.backgroundColor = .systemGray6
        } else {
            // Fallback on earlier versions
            aView?.backgroundColor = .black
        }
        guard let newView = aView else { fatalError("View unable to unwrapped in extetion") }
            let activityIndicator = UIActivityIndicatorView()
            activityIndicator.center = newView.center
            activityIndicator.startAnimating()
            newView.addSubview(activityIndicator)
            self.view.addSubview(newView)
    }
    func removeSpinner() {
        aView?.removeFromSuperview()
        aView = nil
    }
}
