//
//  PayPromotionViewController.swift
//  albumdiary
//
//  Created by nonakashiho on 2022/07/02.
//

import UIKit

final class PayPromotionViewController: UIViewController {
    
    
    @IBOutlet private weak var remainingFreePrintCount: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let freePrintCount = UserDefaultUtility().freePrintCountPerMonth()
        remainingFreePrintCount.text = "今月の無料印刷枚数：\(freePrintCount)枚"
    }
    
    @IBAction func pay5Print(_ sender: Any) {
        StoreKitManager.shared.purchaseItemFromAppStore(productId: "singlePrintTicket")
    }
    
    @IBAction func pay50Print(_ sender: Any) {
        StoreKitManager.shared.purchaseItemFromAppStore(productId: "multiPrintTicket")
    }
    
    @IBAction func paySubscriptionPerMonth(_ sender: Any) {
        StoreKitManager.shared.purchaseItemFromAppStore(productId: "subscPrintTicket")
    }
    
    /// 課金についての利用規約ページへ飛ぶ
    @IBAction func useTermsLinkButton(_ sender: Any) {
        let url = NSURL(string: "https://shimarisu55.github.io/albumdiary/UseTerms/index.html") // 外部ブラウザ（Safari）で開く
        if UIApplication.shared.canOpenURL(url! as URL){
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
    }
    
    /// プライバシーポリシーページへ飛ぶ
    @IBAction func privacyPolicyLinkButton(_ sender: Any) {
        let url = NSURL(string: "https://shimarisu55.github.io/albumdiary/PrivacyPolicy/index.html") // 外部ブラウザ（Safari）で開く
        if UIApplication.shared.canOpenURL(url! as URL){
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
    }
    
}
