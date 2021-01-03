//
//  URL+.swift
//  Flat Assets
//
//  Created by Amit Samant on 03/01/21.
//

import Foundation

extension URL {

    
    func extractImageURLs() -> [URL] {
        let filemanager = FileManager.default
        let files = filemanager.enumerator(atPath: self.path)
        var imageUrls: [URL] = []
        while let file = files?.nextObject() {
            guard let fileRelativePath = file as? String,
                  fileRelativePath.containsAssetScaling else {
                continue
            }
            let imageUrl = self.appendingPathComponent(fileRelativePath)
            imageUrls.append(imageUrl)
        }
        return imageUrls
    }

    enum AssetError: Error {
        case invalidHierarchy
        case scalingNotFound
    }
    func getAssetScaledNameByContainingFolder() throws -> (String, AssetScale) {
        guard pathComponents.count >= 2 else {
            throw AssetError.invalidHierarchy
        }
        let containingFolderName = pathComponents[pathComponents.count - 2]
        let fileNameWithExtension = pathComponents[pathComponents.count - 1]
        for scale in AssetScale.allCases {
            if containingFolderName.contains(scale: scale) {
                let fileComponents = fileNameWithExtension.components(separatedBy: ".")
                guard let fileName = fileComponents.first?.trimmingCharacters(in: .whitespaces),
                      let fileExtension = fileComponents.last else {
                    continue
                }
                let assetName = fileName + scale.rawValue + "." + fileExtension
                return (assetName, scale)
            }
        }
        throw AssetError.scalingNotFound
    }
}
