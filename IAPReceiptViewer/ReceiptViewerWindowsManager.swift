//
//  ReceiptViewerWindowsManager.swift
//  IAPReceiptViewer
//
//  Created by Manabu Nakazawa on 1/7/21.
//

import Foundation
import AppKit
import TPInAppReceipt
import SwiftUI

enum ReceiptViewerWindowsManager {
    static var windowControllers = NSHashTable<NSWindowController>.weakObjects()
    
    static func showWindow(appURL: URL, parentWindow: NSWindow?) {
        do {
            let viewController = try makeReceiptViewerViewController(appURL: appURL)
            let title = "IAPReceiptViewer - \(appURL.lastPathComponent)"
            let window = NSWindow()
            window.styleMask = [.titled, .closable, .resizable, .miniaturizable]
            window.title = title
            window.setFrameAutosaveName(NSWindow.FrameAutosaveName(title))
            window.contentViewController = viewController
            window.makeKeyAndOrderFront(nil)
            let windowController = NSWindowController(window: window)
            windowControllers.add(windowController)
        } catch {
            let alert = NSAlert()
            alert.alertStyle = .critical
            alert.messageText = "Error"
            alert.informativeText = error.localizedDescription
            if let parentWindow = parentWindow {
                alert.beginSheetModal(for: parentWindow)
            }
        }
    }
    
    static func makeReceiptViewerViewController(appURL: URL) throws -> NSViewController {
        let result = try ReceiptDecoder.decode(appURL: appURL)
        
        let fileInfoHTML = [
            TableRow("App path", result.appURL?.path ?? noneHTML),
            TableRow("Receipt path", result.receiptURL.path),
        ].makeTableHTML()
        
        let html = """
        <html>
        <head>
            <style>
                :root { color-scheme: light dark; }
                * {
                    white-space: nowrap;
                    font-family: -apple-system;
                }
                td { padding: 4px; }
                td.sectitle { font-weight: bold; }
            </style>
        </head>
        <body>
            <h2>File Information</h2>
            \(fileInfoHTML)
            <h2>Data in Receipt</h2>
            \(result.receipt.html)
        </body>
        </html>
        """
        return NSHostingController(
            rootView: WebView(htmlString: html)
                .frame(minWidth: 600, minHeight: 700))
    }
}

private typealias TableRow = (title: String, value: Any)

private extension InAppReceipt {
    var html: String {
        let inAppPurchases = purchases.isEmpty
        ? noneHTML
        : String(describing: purchases.map(\.html).joined(separator: "<hr>"))
        
        let infoTableHTML = [
            TableRow("Environment", payload.environment),
            TableRow("Bundle Identifier", bundleIdentifier),
            TableRow("App Version", appVersion),
            TableRow("Opaque Value", Array(payload.opaqueValue)),
            TableRow("SHA-1 Hash", Array(payload.receiptHash)),
            TableRow("Original Application Version", originalAppVersion),
            TableRow("Receipt Creation Date", dateFormatter.string(from: creationDate)),
            TableRow("Receipt Expiration Date", expirationDate.flatMap { dateFormatter.string(from: $0) } ?? noneHTML),
            TableRow("Age Rating", ageRating),
            TableRow("Base64", base64),
        ].makeTableHTML()
        
        return """
        \(infoTableHTML)
        <h3>In-App Purchases (\(purchases.count) items)</h3>
        \(inAppPurchases)
        """
    }
}

private extension InAppPurchase {
    var html: String {
        return [
            TableRow("Quantity", quantity),
            TableRow("Product identifier", productIdentifier),
            TableRow("Transaction Identifier", transactionIdentifier),
            TableRow("Original Transaction Identifier", originalTransactionIdentifier),
            TableRow("Purchase Date", dateFormatter.string(from: purchaseDate)),
            TableRow("Original Purchase Date", originalPurchaseDate.flatMap { dateFormatter.string(from: $0) } ?? noneHTML),
            TableRow("Subscription Expiration Date", subscriptionExpirationDate.flatMap { dateFormatter.string(from: $0) } ?? noneHTML),
            TableRow("Subscription Trial Period", subscriptionTrialPeriod),
            TableRow("Subscription Introductory Price Period", subscriptionIntroductoryPricePeriod),
            TableRow("Cancellation Date", cancellationDate.flatMap { dateFormatter.string(from: $0) } ?? noneHTML),
            TableRow("Product Type", productType),
            TableRow("Web Order Line Item ID", webOrderLineItemID.flatMap { String(describing: $0) } ?? noneHTML),
            TableRow("Promotional Offer Identifier", promotionalOfferIdentifier.flatMap { String(describing: $0) } ?? noneHTML),
            TableRow("Is Active Auto Renewable Subscription", isActiveAutoRenewableSubscription(forDate: Date())),
        ].makeTableHTML()
    }
}

private extension String {
    func wrappingWithTableHTML() -> String {
        return "<table><tbody>\(self)</tbody></table>"
    }
}

private extension Array where Element == TableRow {
    func makeTableHTML() -> String {
        return reduce(into: "") {
            $0 += makeTableRowHTML(title: $1.title, value: $1.value)
        }
        .wrappingWithTableHTML()
    }
}

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss z"
    return dateFormatter
}()

private func makeTableRowHTML(title: String, value: Any) -> String {
    return """
            <tr>
            <td class="sectitle">\(title)</td>
            <td>\(value)</td>
            </tr>
            """
}

private let noneHTML = #"<p style="color:#888888;">(none)</p>"#
