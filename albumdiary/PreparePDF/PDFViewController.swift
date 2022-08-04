//
//  PDFViewController.swift
//  albumdiary
//
//  Created by nonakashiho on 2022/05/23.
//

import UIKit
import PDFKit

final class PDFViewController: UIViewController {

    var pageSize = "B5"
    @IBOutlet private weak var pdfView: PDFView!
    
    // classで持たないと途中で途切れるので
    var dic: UIDocumentInteractionController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "PDF"
        let printButtonItem = UIBarButtonItem(title: "印刷", style: .done, target: self, action: #selector(confirmPageCount(_:)))
        navigationItem.rightBarButtonItems = [printButtonItem]
        
        // PDF出力
        if let documentURL = PDFUtility().preparePDFFileUrl() {
            if let document = PDFDocument(url: documentURL) {
                pdfView.autoScales = true
                pdfView.document = document
            }
        }
    }
    
    @objc func confirmPageCount(_ sender: AnyObject) {
        let pdfEntities = DiaryLayoutManager.shared.pdfEntities
        let cellCount = Double(pdfEntities.count)
        let pageSizePerCount = pageSize == "A5" ? Double(6) : Double(8)
        let exportedPageCount = Int(ceil(cellCount/pageSizePerCount)) //切り上げ
        
        if isTransitionToBillingPage(exportedPageCount: exportedPageCount) {
            // 課金ページに進む
            transitionToPayPage()
            return
        }
        
        let alert = UIAlertController(title: "\(exportedPageCount)枚分のPDFを\n印刷または保存します", message:  "よろしいですか？", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "はい", style: .default) { _ in
            // PDF印刷消費枠を記録
            self.recordConsumePrintCount(exportedPageCount: exportedPageCount)
            
            self.dismiss(animated: true) {
                self.export()
            }
        }
        // キャンセルボタンの処理
        let cancelAction = UIAlertAction(title: "いいえ", style: .cancel, handler:{ _ in
            self.dismiss(animated: true)
        })
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        present(alert, animated: true, completion: nil)
    }
    
    /// PDFのExport
    func export() {
        // プロジェクト内のファイルを指定したい時
        if let documentURL = PDFUtility().preparePDFFileUrl() {
            dic = UIDocumentInteractionController(url: documentURL)
            dic?.presentOpenInMenu(from: .zero, in: pdfView, animated: true)
        }
    }
    
    /// 試用期間中か、印刷枠が残っているかをみて、課金ページに進むか判断
    /// - Parameter exportedPageCount: 印刷するPDFの枚数
    /// - Returns: true / false
    private func isTransitionToBillingPage(exportedPageCount: Int) -> Bool {
        // サブスクリプションに登録しているか
        if UserDefaultUtility().isSubscription() {
            return false
        }
        // 試用期間終了するか
        if !UserDefaultUtility().isEndFirstTrialTime(),
            UserDefaultUtility().getExportPDFSheets() + exportedPageCount >= 20 {
            UserDefaultUtility().setEndFirstTrialTime()
            // 課金ページに進む
            return true
        }
        // 試用期間終了後、印刷枠(月の無料枠＋課金印刷枠）が残っているか
        let remainingPrintCount = UserDefaultUtility().freePrintCountPerMonth() + UserDefaultUtility().paidPrintCount()
        if UserDefaultUtility().isEndFirstTrialTime(),
           exportedPageCount > remainingPrintCount {
            // 課金ページに進む
            return true
        }
        return false
    }
    
    private func transitionToPayPage() {
        let nextPage = PayPromotionViewController()
        present(nextPage, animated: true)
    }
    
    /// 消費した無料枠/有料印刷枠を記録
    private func recordConsumePrintCount(exportedPageCount: Int) {
        // サブスクリプション中は消費しない
        guard !UserDefaultUtility().isSubscription() else { return }
        // 出力した枚数をuserDefaultで保存
        // 試用期間中
        if !UserDefaultUtility().isEndFirstTrialTime() {
            UserDefaultUtility().setExportPDFSheets(sheetNumber: exportedPageCount)
            return
        }
        // 印刷枠を消費
        UserDefaultUtility().consumeFreePrintCountPerMonth(consumeCount: exportedPageCount)
    }
    
}
