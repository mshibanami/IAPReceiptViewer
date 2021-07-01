//
//  ReceiptSelectionView.swift
//  IAPReceiptViewer
//
//  Created by Manabu Nakazawa on 1/7/21.
//

import SwiftUI
import TPInAppReceipt

struct ReceiptSelectionView: View {
    @Environment(\.parentWindow) var parentWindow
    
    var body: some View {
        Button("Select App including a receipt") {
            onTapSelectReceipt()
        }
        .padding(100)
    }
    
    private func onTapSelectReceipt() {
        guard let parentWindow = parentWindow() else {
            assertionFailure()
            return
        }
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.allowedFileTypes = ["com.apple.application-bundle"]
        panel.beginSheetModal(for: parentWindow) { [weak panel] response in
            guard let panel = panel,
                  response == .OK,
                  let url = panel.url
            else {
                return
            }
            ReceiptViewerWindowsManager.showWindow(appURL: url, parentWindow: parentWindow)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ReceiptSelectionView()
    }
}
