//
//  ReceiptSelectionView.swift
//  IAPReceiptViewer
//
//  Created by Manabu Nakazawa on 1/7/21.
//

import SwiftUI
import TPInAppReceipt

@MainActor struct ReceiptSelectionView: View {
    @Environment(\.parentWindow) var parentWindow
    @State private var dragOver = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round, dash: [10, 10]))
            .foregroundColor(Color(nsColor: NSColor.secondaryLabelColor))
            .overlay {
                VStack(spacing: 14) {
                    Button("Select an app including a receipt") {
                        onTapSelectReceipt()
                    }
                    Text("Or drag & drop.")
                }
            }
            .padding(14)
            .frame(minWidth: 300, minHeight: 200)
            .onDrop(of: ["public.file-url"], isTargeted: $dragOver) { providers -> Bool in
                providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { data, error in
                    guard let data,
                          let path = String(data: data, encoding: .utf8),
                          let url = URL(string: path as String) else {
                        return
                    }
                    Task {
                        await showReceiptWindow(appURL: url)
                    }
                })
                return true
            }
    }
    
    private func onTapSelectReceipt() {
        guard let parentWindow = parentWindow() else {
            assertionFailure()
            return
        }
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.allowedContentTypes = [.application, .applicationBundle, .applicationExtension]
        panel.directoryURL = URL.applicationDirectory
        panel.beginSheetModal(for: parentWindow) { [weak panel] response in
            guard let panel,
                  response == .OK,
                  let url = panel.url else {
                return
            }
            Task {
                await showReceiptWindow(appURL: url)
            }
        }
    }
    
    private func showReceiptWindow(appURL: URL) async {
        guard let parentWindow = parentWindow() else {
            assertionFailure()
            return
        }
        ReceiptViewerWindowsManager.showWindow(appURL: appURL, parentWindow: parentWindow)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ReceiptSelectionView()
    }
}
