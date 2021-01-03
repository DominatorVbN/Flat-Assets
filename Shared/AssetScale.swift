//
//  AssetScale.swift
//  Flat Assets
//
//  Created by Amit Samant on 03/01/21.
//

import Foundation

enum AssetScale: String, CaseIterable {
    case one = "@1x"
    case two = "@2x"
    case three = "@3x"

    var scaleNumber: String {
        switch self {
        case .one:
            return "1x"
        case .two:
            return "2x"
        case .three:
            return "3x"
        }
    }
}
