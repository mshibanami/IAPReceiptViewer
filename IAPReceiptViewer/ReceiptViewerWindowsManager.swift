//
//  ReceiptViewerWindowsManager.swift
//  IAPReceiptViewer
//
//  Created by Manabu Nakazawa on 1/7/21.
//

import AppKit
import Foundation
import SwiftUI
import TPInAppReceipt

@MainActor enum ReceiptViewerWindowsManager {
    static var windowControllers = NSHashTable<NSWindowController>.weakObjects()
    
    static func showWindow(appURL: URL, parentWindow: NSWindow?) {
        do {
            let html = try makeReceiptDetailsHTML(appURL: appURL)
            let title = "IAPReceiptViewer-\(appURL.lastPathComponent)"
            let htmlFileURL = saveHTMLContent(html, title: title)
            if let htmlFileURL {
                NSWorkspace.shared.open(htmlFileURL)
            }
        } catch {
            let alert = NSAlert()
            alert.alertStyle = .critical
            alert.messageText = "Error"
            alert.informativeText = error.localizedDescription
            if let parentWindow {
                alert.beginSheetModal(for: parentWindow)
            }
        }
    }
    
    static func makeReceiptDetailsHTML(appURL: URL) throws -> String {
        let result = try ReceiptDecoder.decode(appURL: appURL)
        
        let fileInfoHTML = [
            TableRow("App path", result.appURL?.path ?? noneHTML),
            TableRow("Receipt path", result.receiptURL.path),
        ].makeTableHTML()
        
        let collapsedTextMaxWidth = 300
        
        let html = """
        <html>
        <head>
            <style>
                :root {
                    color-scheme: light dark;
                }
                body {
                    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
                    margin: 20px;
                    padding: 20px;
                    background-color: var(--background-color);
                    color: var(--text-color);
                    display: flex;
                    justify-content: center;
                    align-items: flex-start;
                }
                .content {
                    width: 80%;
                    max-width: 1200px;
                    min-width: 600px;
                }
                table {
                    width: 100%;
                    border-collapse: collapse;
                    background-color: var(--table-background);
                    margin-top: 20px;
                    border-radius: 8px;
                    overflow: hidden;
                    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
                }
                th, td {
                    padding: 12px 20px;
                    text-align: left;
                    border-bottom: 1px solid var(--border-color);
                    word-break: break-all;
                    overflow: hidden;
                    text-overflow: ellipsis;
                    max-width: 200px;
                    vertical-align: top;
                }
                th {
                    background-color: var(--header-background);
                    color: var(--header-text);
                }
                tr:nth-child(even) {
                    background-color: var(--row-background);
                }
                tr:hover {
                    background-color: var(--hover-background);
                }
                .sectitle {
                    font-weight: bold;
                }
                h2, h3 {
                    color: var(--text-color);
                }
                .expandable-text {
                    display: inline-block;
                    max-width: \(collapsedTextMaxWidth)px;
                    overflow: hidden;
                    text-overflow: ellipsis;
                    white-space: nowrap;
                }
                .show-more {
                    color: #007BFF;
                    cursor: pointer;
                    text-decoration: underline;
                }
                @media (prefers-color-scheme: dark) {
                    :root {
                        --background-color: #121212;
                        --text-color: #cccccc;
                        --table-background: #1e1e1e;
                        --border-color: #333333;
                        --header-background: #263238;
                        --header-text: #ffffff;
                        --row-background: #242424;
                        --hover-background: #2e2e2e;
                    }
                }
                @media (prefers-color-scheme: light) {
                    :root {
                        --background-color: #f4f4f8;
                        --text-color: #333333;
                        --table-background: #ffffff;
                        --border-color: #cccccc;
                        --header-background: #607d8b;
                        --header-text: #ffffff;
                        --row-background: #f9f9f9;
                        --hover-background: #efefef;
                    }
                }
            </style>
            <script>
                function toggleText(button) {
                    var container = button.previousElementSibling; // ボタンの直前の要素 (テキストコンテナ) を取得
                    if (button.textContent === "Show more") {
                        container.style.whiteSpace = "normal";
                        container.style.overflow = "visible";
                        container.style.maxWidth = "none";
                        button.textContent = "Show less";
                    } else {
                        container.style.whiteSpace = "nowrap";
                        container.style.overflow = "hidden";
                        container.style.maxWidth = "\(collapsedTextMaxWidth)px";
                        button.textContent = "Show more";
                    }
                }
            </script>
        </head>
        <body>
            <div class="content">
                <h2>File Information</h2>
                \(fileInfoHTML)
                <h2>Data in Receipt</h2>
                \(result.receipt.html)
            </div>
        </body>
        </html>
        """.replacingOccurrences(of: "\u{202F}", with: "&nbsp;")
        return html
    }
    
    private static func saveHTMLContent(_ content: String, title: String) -> URL? {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.html]
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = "\(title).html"
        panel.title = "Save HTML File"
        panel.message = "Choose a location to save the HTML file of the receipt details."
        panel.directoryURL = URL.downloadsDirectory

        let response = panel.runModal()
        guard response == .OK, let url = panel.url else {
            return nil
        }
        do {
            try content.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            print("Failed to write HTML file: \(error)")
            return nil
        }
    }
}

private typealias TableRow = (title: String, value: Any)

private extension InAppReceipt {
    var html: String {
        let inAppPurchases = purchases.isEmpty
            ? noneHTML
            : String(describing: purchases.map(\.html).joined(separator: "<hr>"))
        
        let infoTableHTML = [
            TableRow("bundleIdentifier", bundleIdentifier),
            TableRow("appVersion", appVersion),
            TableRow("originalAppVersion", originalAppVersion),
            TableRow("originalPurchaseDate", originalPurchaseDate.flatMap { dateFormatter.string(from: $0) } ?? noneHTML),
            TableRow("expirationDate", expirationDate.flatMap { dateFormatter.string(from: $0) } ?? noneHTML),
            TableRow("hasPurchases", hasPurchases),
            TableRow("hasActiveAutoRenewablePurchases", hasActiveAutoRenewablePurchases),
            TableRow("creationDate", dateFormatter.string(from: creationDate)),
            TableRow("ageRating", ageRating),
            TableRow("base64", base64),
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
            TableRow("quantity", quantity),
            TableRow("productIdentifier", productIdentifier),
            TableRow("transactionIdentifier", transactionIdentifier),
            TableRow("originalTransactionIdentifier", originalTransactionIdentifier),
            TableRow("purchaseDate", dateFormatter.string(from: purchaseDate)),
            TableRow("originalPurchaseDate", originalPurchaseDate.flatMap { dateFormatter.string(from: $0) } ?? noneHTML),
            TableRow("subscriptionExpirationDate", subscriptionExpirationDate.flatMap { dateFormatter.string(from: $0) } ?? noneHTML),
            TableRow("subscriptionTrialPeriod", subscriptionTrialPeriod),
            TableRow("subscriptionIntroductoryPricePeriod", subscriptionIntroductoryPricePeriod),
            TableRow("cancellationDate", cancellationDate.flatMap { dateFormatter.string(from: $0) } ?? noneHTML),
            TableRow("productType", productType),
            TableRow("webOrderLineItemID", webOrderLineItemID.flatMap { String(describing: $0) } ?? noneHTML),
            TableRow("promotionalOfferIdentifier", promotionalOfferIdentifier.flatMap { String(describing: $0) } ?? noneHTML),
            isRenewableSubscription
                ? TableRow("Is Active Auto Renewable Subscription", isActiveAutoRenewableSubscription(forDate: Date()))
                : nil,
        ].compactMap { $0 }.makeTableHTML()
    }
}

private extension String {
    func wrappingWithTableHTML() -> String {
        return "<table><tbody>\(self)</tbody></table>"
    }
}

private extension [TableRow] {
    func makeTableHTML() -> String {
        return reduce(into: "") {
            $0 += makeTableRowHTML(title: $1.title, value: $1.value)
        }
        .wrappingWithTableHTML()
    }
}

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .full
    return dateFormatter
}()

private func makeTableRowHTML(title: String, value: Any) -> String {
    let valueString = String(describing: value)
    
    let maxLength = 100
    let valueTDContent = valueString.count > maxLength
        ? """
            <div class="expandable-text">\(valueString)</div>
            <p class="show-more" onclick="toggleText(this)">Show more</p>
        """
        : valueString
    
    return """
    <tr>
        <td class="sectitle">\(title)</td>
        <td>\(valueTDContent)</td>
    </tr>
    """
}

private let noneHTML = #"<p style="color:#888888;">(none)</p>"#
