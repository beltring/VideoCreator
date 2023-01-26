//
//  UIImage+Init.swift
//  VideoCreator
//
//  Created by Pavel Boltromyuk on 26.01.23.
//

import UIKit

extension UIImage{

    convenience init(view: UIView) {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: image!.cgImage!)
    }
}
