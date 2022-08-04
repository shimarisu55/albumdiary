//
//  StoreKitManager.swift
//  albumdiary
//
//  Created by nonakashiho on 2022/07/14.
//

import Foundation
import StoreKit
import SwiftyStoreKit

final class StoreKitManager {
   private init() {}
   static let shared = StoreKitManager()
   
   // 購入
    func purchaseItemFromAppStore(productId: String) {

        SwiftyStoreKit.purchaseProduct(productId, quantity: 1, atomically: true) { result in
            switch result {
            case .success(let purchase):
                print("Purchase Success: \(purchase.productId)")
                // 購入の検証
                self.verifyPurchase(productId: productId)
                
            case .error(let error):
                switch error.code {
                case .unknown: print("Unknown error. Please contact support")
                case .clientInvalid: print("Not allowed to make the payment")
                case .paymentCancelled: break
                case .paymentInvalid: print("The purchase identifier was invalid")
                case .paymentNotAllowed: print("The device is not allowed to make the payment")
                case .storeProductNotAvailable: print("The product is not available in the current storefront")
                case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                @unknown default: break
                }
            }
        }
    }
    
    // サブスクリプション中か確認し、期限が切れていたらUserDefaultを更新
    func confirmSubscription(productId: String) {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: secretToken)
            SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
                switch result {
                case .success(let receipt):
                    //自動更新なし(30日間)
                    let purchaseResult = SwiftyStoreKit.verifySubscription(
                        ofType: .nonRenewing(validDuration: 3600 * 24 * 30),
                        productId: productId,
                        inReceipt: receipt)

                    switch purchaseResult {
                    case .purchased:
                        //リストアの成功
                        UserDefaultUtility().setSubscription(isPaid: true)
                    case .notPurchased:
                        //リストアの失敗
                        UserDefaultUtility().setSubscription(isPaid: false)
                    case .expired(expiryDate: let expiryDate, items: let items):
                        // 期限切れ
                        UserDefaultUtility().setSubscription(isPaid: false)
                    }
                case .error: break
                    //エラー
                }
            }
    }
    
    // 復元　古い端末でサブスクリプションを購入した場合、新しい端末でも使用可能にする
    func restoreSubscription() {
        SwiftyStoreKit.restorePurchases(atomically: false) { results in
            guard results.restoredPurchases.count > 0 else {
                // 失敗
                return
            }
            for purchase in results.restoredPurchases {
                // fetch content from your server, then:
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
            }
            print("Restore Success: \(results.restoredPurchases)")
            // 成功
            UserDefaultUtility().setSubscription(isPaid: true)
        }
    }
   
    // リストア レシートを検証後、userDefaultを操作
    private func verifyPurchase(productId: String) {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: secretToken)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                let purchaseResult = SwiftyStoreKit.verifyPurchase(productId: productId, inReceipt: receipt)
                switch purchaseResult {
                case .purchased:
                    //リストアの成功
                    self.purchasePrintTicket(productId: productId)
                case .notPurchased:
                    //リストアの失敗
                    break
                }
            case .error:
                //エラー
                break
            }
        }
    }
    
    /// 印刷5枚か50枚分購入した時、userDefaultに保存する
    private func purchasePrintTicket(productId: String) {
        switch productId {
        case "singlePrintTicket":
            // 単発買い
            UserDefaultUtility().setPaidPrintCount(count: 5)
        case "multiPrintTicket":
            // まとめ買い
            UserDefaultUtility().setPaidPrintCount(count: 50)
        case "subscPrintTicket":
            UserDefaultUtility().setSubscription(isPaid: true)
        default:
            break // 何もしない
        }
    }
}
