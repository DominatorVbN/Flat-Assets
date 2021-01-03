//
//  String+.swift
//  Flat Assets
//
//  Created by Amit Samant on 03/01/21.
//

import Foundation

extension String {
    func contains(scale: AssetScale) -> Bool {
        self.contains(scale.rawValue)
    }
    var containsAssetScaling: Bool {
        for assetScale in AssetScale.allCases {
            if self.contains(assetScale.rawValue) {
                return true
            }
        }
        return false
    }

    var containsPngExtension: Bool {
        return self.contains(".png")
    }

    func folderName() -> String {
        guard let scale = getAssetScale() else {
            return self.trimmingCharacters(in: .whitespaces)
        }
        return self.getNameWithoutScale(scale: scale) ?? self.trimmingCharacters(in: .whitespaces)
    }

    func cleanName() -> String {
        guard let scale = getAssetScale() else {
            return self
        }
        return correctName(forScale: scale)
    }

    func correctName(forScale scale: AssetScale) -> String {
        let components = self.components(separatedBy: ".")
        guard let fileName = components.first,
              let fileExtension = components.last else {
            return self
        }
        guard let nameWithoutScale = fileName.getNameWithoutScale(scale: scale) else {
            return self
        }
        return nameWithoutScale + scale.rawValue + "." + fileExtension
    }

    func getNameWithoutScale(scale: AssetScale) -> String? {
        let components = self.components(separatedBy: scale.rawValue)
        for text in components {
            if text.count > 0 {
                return text.trimmingCharacters(in: .whitespaces)
            }
        }
        return nil
    }

    func getAssetScale() -> AssetScale? {
        for scale in AssetScale.allCases {
            if self.contains(scale: scale) {
                return scale
            }
        }
        return nil
    }
}
