//
//  AssetGenerator.swift
//  Flat Assets
//
//  Created by Amit Samant on 04/01/21.
//

import Foundation

class AssetGenerator {

    let fileManager = FileManager()
    let tempFolderName = UUID().uuidString

    var cacheURL: URL {
        guard let url = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            fatalError("Unable to locate cache url")
        }
        return url.appendingPathComponent(tempFolderName)
    }


    func generateAssets(forUrls urls: [URL], _ completion: @escaping ([URL]) -> Void) {
        let bgQueue = DispatchQueue(label: "AssetExtractionQueue", qos: .userInitiated)
        bgQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            let urls = urls.compactMap(self.exportAsset(url:))
            completion(urls)
        }
    }

    func cleanCache() {
        guard let directoryContents = try? FileManager.default.contentsOfDirectory( at: cacheURL, includingPropertiesForKeys: nil, options: []) else {
            return
        }
        for file in directoryContents {
            do {
                try fileManager.removeItem(at: file)
            }
            catch let error as NSError {
                debugPrint("Ooops! Something went wrong: \(error)")
            }
        }
    }

    func exportAsset(url: URL) -> URL? {
        let fileEnumerator = fileManager.enumerator(atPath: url.path)
        var images: [Image] = []
        var folderName: String? {
            didSet {
                guard let folder = folderName else {
                    return
                }
                let url = cacheURL.appendingPathComponent(folder)
                try? fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: [:])
            }
        }
        while let fileName = fileEnumerator?.nextObject() as? String {
            if fileName.containsAssetScaling && fileName.containsPngExtension {
                let imageURL = url.appendingPathComponent(fileName)
                let assetName: String?
                let assetScale: AssetScale?
                if fileName.containsAssetScaling, let name = imageURL.pathComponents.last {
                    assetName = name.cleanName()
                    assetScale = name.getAssetScale()
                } else {
                    do {
                        let assetNameScaleTuple = try imageURL.getAssetScaledNameByContainingFolder()
                        assetName = assetNameScaleTuple.0
                        assetScale = assetNameScaleTuple.1
                    } catch {
                        print(error)
                        assetName = nil
                        assetScale = nil
                    }
                }
                folderName = (assetName?.folderName() ?? "random") + ".imageset"
                guard let fileName = assetName,
                      let fileScale = assetScale,
                      let folder = folderName else {
                    continue
                }

                let destinationURL = cacheURL
                    .appendingPathComponent(folder)
                    .appendingPathComponent(fileName)

                print(destinationURL)

                images.append(Image(filename: fileName, scale: fileScale))

                do {
                    try fileManager.copyItem(at: imageURL, to: destinationURL)
                } catch {
                    print(error)
                }

                guard let assetData = try? Asset(images: images).jsonData() else {
                    continue
                }

                do {
                    try assetData.write(to: cacheURL
                                        .appendingPathComponent(folder)
                                        .appendingPathComponent("Contents.json")
                    )
                } catch {
                    print(error)
                }
            }
        }
        guard let folder = folderName else {
            return nil
        }
        return cacheURL
            .appendingPathComponent(folder)
    }
}
