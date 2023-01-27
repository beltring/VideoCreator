//
//  Effect.swift
//  VideoCreator
//
//  Created by Pavel Boltromyuk on 26.01.23.
//

import UIKit

public enum Effect: CaseIterable {
    case screwing
    case pushLeft
    case pushRight
    case pushUp
    case pushDown
    case none

    var title: String {
        switch self {
        case .none:
            return "Without effect"
        case .pushRight:
            return "From left to right"
        case .pushLeft:
            return "From right to left"
        case .pushUp:
            return "From down to up"
        case .pushDown:
            return "From up to down"
        case .screwing:
            return "Screwing"
        }
    }

    var image: UIImage? {
        switch self {
        case .none:
            return UIImage(named: "closeSquare")
        case .pushRight:
            return UIImage(named: "arrowRight")
        case .pushLeft:
            return UIImage(named: "arrowLeft")
        case .pushUp:
            return UIImage(named: "arrowUp")
        case .pushDown:
            return UIImage(named: "arrowDown")
        case .screwing:
            return UIImage(named: "screwing")
        }
    }
}
