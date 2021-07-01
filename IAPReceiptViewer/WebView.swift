//
//  WebView.swift
//  IAPReceiptViewer
//
//  Created by Manabu Nakazawa on 4/7/21.
//

import AppKit
import SwiftUI
import WebKit

struct WebView: NSViewRepresentable {
    var htmlString: String
    
    func makeNSView(context: NSViewRepresentableContext<WebView>) -> WKWebView {
        let webview = WKWebView()
        webview.loadHTMLString(htmlString, baseURL: nil)
        return webview
    }
    
    func updateNSView(_ webview: WKWebView, context: NSViewRepresentableContext<WebView>) {
        webview.loadHTMLString(htmlString, baseURL: nil)
    }
}
