//
//  ReceiptDecoder.swift
//  IAPReceiptViewer
//
//  Created by Manabu Nakazawa on 1/7/21.
//

import Foundation
import TPInAppReceipt

enum ReceiptDecoder {
    enum ReceiptDecoderError: Error, LocalizedError {
        case urlIsNotFilePath
        case fileIsNotApp
        case fileNotFound
        case receiptNotFound
        case infoPlistNotFound
        case infoPlistIsUnreadable
        
        var errorDescription: String? {
            switch self {
            case .urlIsNotFilePath:
                return "Specified URL is not a file path."
            case .fileIsNotApp:
                return "Specified file is not an app."
            case .fileNotFound:
                return "Specified file doesn't exist."
            case .receiptNotFound:
                return "Specified app doesn't include a receipt."
            case .infoPlistNotFound:
                return "Specified app doesn't include Info.plist."
            case .infoPlistIsUnreadable:
                return "Specified app has an unreadable Info.plist."
            }
        }
    }
    
    struct ReceiptDecodingResult {
        var appURL: URL?
        var receiptURL: URL
        var receipt: InAppReceipt
    }
    
    static func decode(appURL: URL) throws -> ReceiptDecodingResult {
        guard appURL.isFileURL else {
            throw ReceiptDecoderError.urlIsNotFilePath
        }
        guard appURL.pathExtension == "app" else {
            throw ReceiptDecoderError.fileIsNotApp
        }
        guard FileManager.default.fileExists(atPath: appURL.path) else {
            throw ReceiptDecoderError.fileNotFound
        }
        let receiptURL = appURL.appendingPathComponent("Contents/_MASReceipt/receipt")
        guard FileManager.default.fileExists(atPath: receiptURL.path) else {
            throw ReceiptDecoderError.receiptNotFound
        }
        
        return try ReceiptDecodingResult(
            appURL: appURL,
            receiptURL: receiptURL,
            receipt: InAppReceipt(receiptData: Data(contentsOf: receiptURL))
        )
    }
}
