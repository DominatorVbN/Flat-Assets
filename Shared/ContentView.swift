//
//  ContentView.swift
//  Shared
//
//  Created by Amit Samant on 19/12/20.
//

import SwiftUI

extension URL {
    var folderName: String {
        pathComponents.last!
    }
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
}


enum AssetScale: String, CaseIterable {
    case one = "@1x"
    case two = "@2x"
    case three = "@3x"
}

extension String {
    var containsAssetScaling: Bool {
        for assetScale in AssetScale.allCases {
            if self.contains(assetScale.rawValue) {
                return true
            }
        }
        return false
    }
}

struct ContentView: View {
    @State private var folder: URL?
    @State var isActiveBorder = false

    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [2]))
                    .foregroundColor(isActiveBorder ? .red : .gray)
                if folder != nil {
                    VStack {
                        Image(systemName: "folder.fill")
                            .font(.largeTitle)
                            .foregroundColor(.accentColor)
                        Text(folder!.folderName)
                    }
                }
            }
            .onDrop(
                of: [.fileURL],
                delegate: FolderDropDelegate(
                    fileURL: $folder,
                    isInsideView: $isActiveBorder
                )
            )
            Button("Extract", action: actionExtract)
        }
        .padding()
        .frame(width: 300, height: 300)
        
    }
    
    
    
    func actionExtract() {
        guard let link = folder else {
            return
        }
        let fileManager = FileManager()
        let files = fileManager.enumerator(atPath: link.path)
        var imageRelativePaths: [String] = []
        while let file = files?.nextObject() {
            let path = file as! String
            if ( path.contains("@1x") || path.contains("@2x") || path.contains("@3x") ) && path.contains(".png") {
                print(file)
                imageRelativePaths.append(path)
            }
        }
        let dir = link.appendingPathComponent("extracted")
        let fileurls = imageRelativePaths.map {
            link.appendingPathComponent($0)
        }
        do {
            try fileManager.createDirectory(
                at: dir,
                withIntermediateDirectories: false,
                attributes: nil
            )
        } catch {
            print(dir)
        }
        
        for imageUrl in fileurls {
            let newUrl: URL
            if !(imageUrl.pathComponents.last!.contains("@1x") ||
                imageUrl.pathComponents.last!.contains("@2x") ||
                imageUrl.pathComponents.last!.contains("@3x")) {
                if imageUrl.pathComponents[imageUrl.pathComponents.count - 2].contains("@1x") {
                    let name = imageUrl.pathComponents.last!.components(separatedBy: ".").first! + "@1x." + imageUrl.pathComponents.last!.components(separatedBy: ".").last!
                    newUrl = dir.appendingPathComponent(name)
                } else if imageUrl.pathComponents[imageUrl.pathComponents.count - 2].contains("@2x") {
                    let name = imageUrl.pathComponents.last!.components(separatedBy: ".").first! + "@2x." + imageUrl.pathComponents.last!.components(separatedBy: ".").last!
                    newUrl = dir.appendingPathComponent(name)
                } else if imageUrl.pathComponents[imageUrl.pathComponents.count - 2].contains("@3x") {
                    let name = imageUrl.pathComponents.last!.components(separatedBy: ".").first! + "@3x." + imageUrl.pathComponents.last!.components(separatedBy: ".").last!
                    newUrl = dir.appendingPathComponent(name)
                } else {
                    fatalError()
                }
            } else {
                newUrl = dir.appendingPathComponent(imageUrl.pathComponents.last!)
            }
            do {
                try fileManager.moveItem(at: imageUrl, to: newUrl)
            } catch {
                print(error)
            }
        }
        
    }
}

struct FolderDropDelegate: DropDelegate {
    @Binding var fileURL: URL?
    @Binding var isInsideView: Bool

    func performDrop(info: DropInfo) -> Bool {
        print(info)
        guard info.hasItemsConforming(to: [.fileURL]) else {
            return false
        }
        let items = info.itemProviders(for: [.fileURL])
        for item in items {
            _ = item.loadObject(ofClass: URL.self) { url, _ in
                if let url = url {
                    DispatchQueue.main.async {
                        self.fileURL = url
                    }
                }
            }
        }

        return true
    }
    func validateDrop(info: DropInfo) -> Bool {
        info.hasItemsConforming(to: [.fileURL])
    }
    func dropEntered(info: DropInfo) {
        isInsideView = true
    }
    func dropExited(info: DropInfo) {
        isInsideView = false
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
