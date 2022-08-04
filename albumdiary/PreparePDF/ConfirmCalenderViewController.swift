//
//  ConfirmCalenderViewController.swift
//  albumdiary
//
//  Created by nonakashiho on 2021/12/05.
//

import UIKit

final class ConfirmCalenderViewController: UIViewController {
    
    var selectedFromDate = Date()
    private var numberOfSheets = 1
    private var pageSize = "B5"
    @IBOutlet private weak var fromDate: UIDatePicker!
    @IBOutlet private weak var pageCountSegment: UISegmentedControl!
    @IBOutlet private weak var pageSizeSegment: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fromDate.date = selectedFromDate
    }
    
    /// PDF何枚分かを決める
    @IBAction func pageCountSegmented(_ sender: UISegmentedControl) {
        guard let numString = sender.titleForSegment(at: sender.selectedSegmentIndex),
        let number = Int(numString) else { return }
        numberOfSheets = number
    }
    
    /// 紙のサイズを決める（B5,A4,A5）
    @IBAction func pageSizeSegmented(_ sender: UISegmentedControl) {
        pageSize = sender.titleForSegment(at: sender.selectedSegmentIndex) ?? "B5"
    }
    
    @IBAction func tapNextPreparePDF(_ sender: Any) {
        // 対象日付をもとに、データを取り出し、ページごとにまとめる
        DiaryLayoutManager.shared.preparePDFContents(fromDate: fromDate.date,
                                                     numberOfSheets: numberOfSheets,
                                                     pageSize: pageSize)
        PDFUtility().createPdfFromView(saveToDocumentsWithFileName: "view.pdf", pageSize: pageSize)
        // カレンダーで出力範囲を選んだ後PDFに出力
        let nextPageVC = PDFViewController()
        nextPageVC.pageSize = pageSize
        navigationController?.pushViewController(nextPageVC, animated: true)
    }
    
}
    
