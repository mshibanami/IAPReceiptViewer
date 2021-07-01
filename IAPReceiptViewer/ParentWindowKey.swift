//
//  ParentWindowKey.swift
//  IAPReceiptViewer
//
//  Created by Manabu Nakazawa on 1/7/21.
//

import AppKit
import SwiftUI

struct ParentWindowKey: EnvironmentKey {
    typealias Value = () -> NSWindow?
    static let defaultValue: Self.Value = { nil }
}

extension EnvironmentValues {
    var parentWindow: ParentWindowKey.Value {
        get {
            return self[ParentWindowKey.self]
        }
        set {
            self[ParentWindowKey.self] = newValue
        }
    }
}
