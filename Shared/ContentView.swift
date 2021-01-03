//
//  ContentView.swift
//  Shared
//
//  Created by Amit Samant on 19/12/20.
//

import SwiftUI
struct ContentView: View {

    @State private var folder: [URL] = []
    @State var isActiveBorder = false

    @State var showExporter = false
    @State var exportURLs: [URL] = []

    let assetGenerator = AssetGenerator()

    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [2]))
                    .foregroundColor(isActiveBorder ? .red : .gray)
                List(folder, id: \.absoluteURL) { url in
                    VStack {
                        Text(url.pathComponents.last!)
                    }
                }.padding()
            }
            .onDrop(
                of: [.fileURL],
                delegate: FolderDropDelegate(
                    fileURL: $folder,
                    isInsideView: $isActiveBorder
                )
            )
            Button("Export", action: actionExport)
        }
        .padding()
        .frame(width: 300, height: 300)
        .fileMover(isPresented: $showExporter, files: exportURLs) { result in
            switch result {
            case .success(let url):
                print("Success! \(url)")
            case .failure(let error):
                print("Oops: \(error.localizedDescription)")
            }
        }
    }

    func actionExport() {
        assetGenerator.generateAssets(forUrls: folder) { urls in
            self.exportURLs = urls
            self.showExporter = true
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
