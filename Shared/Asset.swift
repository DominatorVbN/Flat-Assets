//
//  Asset.swift
//  Flat Assets
//
//  Created by Amit Samant on 03/01/21.
//

import Foundation

// MARK: - Asset
struct Asset: Codable {
    let images: [Image]
    let info: Info = .init()

    enum CodingKeys: String, CodingKey {
        case images = "images"
        case info = "info"
    }

    func jsonData() throws -> Data {
        
        return try JSONEncoder().encode(self)
    }
}

// MARK: - Image
struct Image: Codable {
    let filename: String
    let idiom: String
    let scale: String

    init(filename: String, scale: AssetScale) {
        self.filename = filename
        self.idiom = "universal"
        self.scale = scale.scaleNumber
    }

    enum CodingKeys: String, CodingKey {
        case filename = "filename"
        case idiom = "idiom"
        case scale = "scale"
    }
}

// MARK: - Info
struct Info: Codable {
    let author: String = "xcode"
    let version: Int = 1

    enum CodingKeys: String, CodingKey {
        case author = "author"
        case version = "version"
    }
}
