//
//  FolderDropDelegate.swift
//  Flat Assets
//
//  Created by Amit Samant on 03/01/21.
//

import SwiftUI

struct FolderDropDelegate: DropDelegate {
    @Binding var fileURL: [URL]
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
                        self.fileURL.append(url)
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
