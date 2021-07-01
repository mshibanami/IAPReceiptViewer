//
//  AppDelegate.swift
//  IAPReceiptViewer
//
//  Created by Manabu Nakazawa on 1/7/21.
//

import Cocoa
import Combine
import SwiftUI
import TPInAppReceipt

class AppDelegate: NSObject, NSApplicationDelegate {
    var windowController: NSWindowController?
    
    private var cancellables: Set<AnyCancellable> = []
    
    func applicationWillFinishLaunching(_ notification: Notification) {
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApp.mainMenu = MainMenuManager.shared.mainMenu
        setupWindow()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func application(_ sender: NSApplication, openFiles filenames: [String]) {
        for filename in filenames {
            ReceiptViewerWindowsManager.showWindow(
                appURL: URL(fileURLWithPath: filename),
                parentWindow: nil)
        }
    }
    
    private func setupWindow() {
        let window = NSWindow()
        window.styleMask = [.titled, .closable, .resizable, .miniaturizable]
        window.contentViewController = NSHostingController(
            rootView: ReceiptSelectionView()
                .environment(\.parentWindow, { [weak window] in window }))
        let windowController = NSWindowController(window: window)
        windowController.showWindow(self)
        self.windowController = windowController
    }
}

extension NSApplication {
    var appDelegate: AppDelegate {
        return delegate as! AppDelegate
    }
}
