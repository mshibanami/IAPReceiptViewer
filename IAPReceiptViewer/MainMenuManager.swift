//
//  MainMenuManager.swift
//  IAPReceiptViewer
//
//  Created by Manabu Nakazawa on 2/5/21.
//  Copyright © 2021 Manabu Nakazawa. All rights reserved.
//

import Cocoa

class MainMenuManager {
    static let shared = MainMenuManager()
    
    lazy var mainMenu: NSMenu = {
        let menu = NSMenu(title: "MainMenu")
        
        let menuList: [(String, (NSMenu) -> ([NSMenuItem]))] = [
            ("IAPReceiptViewer", { (menu: NSMenu) in
                [
                    NSMenuItem(
                        title: "Hide App",
                        action: #selector(NSApp.hide(_:)),
                        keyEquivalent: "h"
                    ),
                    NSMenuItem(
                        title: "Hide Others",
                        action: #selector(NSApp.hideOtherApplications(_:)),
                        keyEquivalent: "h",
                        keyEquivalentModifierMask: [.command, .option]
                    ),
                    NSMenuItem(
                        title: "Show All",
                        action: #selector(NSApp.unhideAllApplications(_:)),
                        keyEquivalent: ""
                    ),
                    NSMenuItem.separator(),
                    NSMenuItem(
                        title: "Quit App",
                        action: #selector(NSApp.terminate(_:)),
                        keyEquivalent: "q"
                    ),
                ]
            }),
            ("File", { (menu: NSMenu) in
                [
                    NSMenuItem(title: "Close Window", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w"),
                ]
            }),
            ("Edit", { (menu: NSMenu) in
                [
                    NSMenuItem(title: "Undo", action: Selector(("undo:")), keyEquivalent: "z"),
                    NSMenuItem(title: "Redo", action: Selector(("redo:")), keyEquivalent: "Z"),
                    NSMenuItem.separator(),
                    NSMenuItem(title: "Cut", action: #selector(NSTextView.cut(_:)), keyEquivalent: "x"),
                    NSMenuItem(title: "Copy", action: #selector(NSTextView.copy(_:)), keyEquivalent: "c"),
                    NSMenuItem(title: "Paste", action: #selector(NSTextView.paste(_:)), keyEquivalent: "v"),
                    NSMenuItem.separator(),
                    NSMenuItem(title: "Select All", action: #selector(NSTextView.selectAll(_:)), keyEquivalent: "a"),
                ]
            }),
            ("Window", { (menu: NSMenu) in
                [
                    NSMenuItem(title: "Minimize", action: #selector(NSWindow.performMiniaturize(_:)), keyEquivalent: ""),
                    NSMenuItem(title: "Zoom", action: #selector(NSWindow.performZoom(_:)), keyEquivalent: ""),
                    NSMenuItem.separator(),
                    NSMenuItem(title: "Bring All to Front", action: #selector(NSApplication.arrangeInFront(_:)), keyEquivalent: ""),
                ]
            }),
        ]
        
        for (menuTitle, itemsListFunc) in menuList {
            let menuItem = NSMenuItem(title: menuTitle, action: nil, keyEquivalent: "")
            menu.addItem(menuItem)
            let submenu = NSMenu(title: menuTitle)
            for i in itemsListFunc(submenu) {
                submenu.addItem(i)
            }
            menuItem.submenu = submenu
        }
        
        return menu
    }()
    
    private init() {}
}

extension NSMenu {
    private func removeFromSuperMenuItem() {
        let servicesMenu = NSApp.servicesMenu
        let supermenu = servicesMenu?.supermenu
        supermenu?.removeItem(at: (supermenu?.indexOfItem(withSubmenu: servicesMenu))!)
    }
}

extension NSMenuItem {
    convenience init(title string: String, action selector: Selector?, target: AnyObject? = nil, keyEquivalent charCode: String, keyEquivalentModifierMask: NSEvent.ModifierFlags) {
        self.init(title: string, action: selector, keyEquivalent: charCode)
        self.target = target
        self.keyEquivalentModifierMask = keyEquivalentModifierMask
    }
}
