//
//  UIViewController+Alert.swift
//  VideoCreator
//
//  Created by Pavel Boltromyuk on 25.01.23.
//

import UIKit

extension UIViewController {

    func presentAlert(title: String? = nil,
                      titleColor: UIColor = .black,
                      message: String? = nil,
                      preferredStyle: UIAlertController.Style = .alert,
                      cancelTitle: String = NSLocalizedString("Cancel", comment: ""),
                      cancelStyle: UIAlertAction.Style = .cancel,
                      cancelHandler: ((UIAlertAction) -> Void)? = nil,
                      otherActions: [UIAlertAction]? = nil,
                      animated: Bool = true,
                      completion: (() -> Void)? = nil) {

        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)

            if let title = title {
                let attributedString = NSAttributedString(string: title, attributes: [.foregroundColor: titleColor])
                alert.setValue(attributedString, forKey: "attributedTitle")
            }

            alert.addAction(UIAlertAction(title: cancelTitle, style: cancelStyle, handler: cancelHandler))
            otherActions?.forEach { alert.addAction($0) }

            self?.present(alert, animated: animated, completion: completion)
        }
    }
}
