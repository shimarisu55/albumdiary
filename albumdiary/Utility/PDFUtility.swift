//
//  PDFUtility.swift
//  albumdiary
//
//  Created by nonakashiho on 2022/05/23.
//

import UIKit

final class PDFUtility {
    // 横の余白
    private let widthMargin = CGFloat(30)
    // 縦の余白
    private let heightMargin = CGFloat(20)
    
    // 日記をpdfファイルに出力し、pdfを保存
    func createPdfFromView(saveToDocumentsWithFileName fileName: String, pageSize: String) {
        var pdfViews = [UIView]()
        if pageSize == "A4" || pageSize == "B5" {
            pdfViews = create8CellsPDFViews(pageSize: pageSize)
        } else if pageSize == "A5" {
            pdfViews = create6CellsPDFViews(pageSize: pageSize)
        }
        if let documentDirectories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let documentsFileName = documentDirectories + "/" + fileName
            UIGraphicsBeginPDFContextToFile(documentsFileName, .zero, nil)
            guard let context = UIGraphicsGetCurrentContext() else { return }
            pdfViews.forEach {
                UIGraphicsBeginPDFPageWithInfo($0.bounds, nil)
                $0.layer.render(in: context)
            }
            UIGraphicsEndPDFContext()
        }
    }
    
    /// 作成したpdfのパスを返す
    func preparePDFFileUrl() -> URL? {
        // uuid付きのファイルのurl
        guard let url = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else { return nil }
        let fileName = "view.pdf"
        let path = url.appendingPathComponent(fileName)
        return path
    }
    
    /// データを８個ずつ分けてUIViewを生成
    private func create8CellsPDFViews(pageSize: String) -> [UIView] {
        let pdfEntities = DiaryLayoutManager.shared.pdfEntities
        let pageSizeWidth = preparePageSizeWidth(pageSize: pageSize)
        let pageSizeHeight = preparePageSizeHeight(pageSize: pageSize)
        var pdfViews = [UIView]()
        var pdfView = UIView(frame: CGRect(x: 0, y: 0, width: pageSizeWidth, height: pageSizeHeight))
        var x = widthMargin
        var y = heightMargin
        for i in 0..<pdfEntities.count {
            x = i % 2 == 0 ? widthMargin : pageSizeWidth/2 // 偶数回の時は左、奇数回の時は右に位置
            if i % 8 == 0 {
                y = heightMargin // ページの一段目
            } else {
                y += i % 2 == 0 ? (pageSizeHeight-heightMargin*2)/4 : 0 // ページの2~4段目、偶数回目の時、次の段にいく
            }
            
            let frame = CGRect(x: x, y: y,
                               width: pageSizeWidth/2-widthMargin,
                               height: (pageSizeHeight-heightMargin*2)/4)
            
            if pdfEntities[i].image != nil {
                // 写真
                let picView = UINib(nibName: "PictureView", bundle: Bundle(for: type(of: self))).instantiate(withOwner: nil, options: nil).first as! PictureView
                picView.frame = frame
                picView.setup(diaryEntity: pdfEntities[i])
                picView.setupFrame(width: pageSizeWidth/2-widthMargin,
                                   height: (pageSizeHeight-heightMargin*2)/4)
                pdfView.addSubview(picView)
            }
            if !pdfEntities[i].diary.isEmpty {
                // 日記
                let diaryView = UINib(nibName: "DiaryView", bundle: Bundle(for: type(of: self))).instantiate(withOwner: nil, options: nil).first as! DiaryView
                diaryView.frame = frame
                diaryView.setup(diaryEntity: pdfEntities[i])
                diaryView.setupFrame(width: pageSizeWidth/2 - widthMargin,
                                     height: (pageSizeHeight-heightMargin*2)/4)
                pdfView.addSubview(diaryView)
            }
            // 8回分描写したら次のページへ進む
            if i % 8 == 7 {
                pdfViews.append(pdfView)
                // 初期化
                x = widthMargin
                y = heightMargin
                pdfView = UIView(frame: CGRect(x: 0, y: 0, width: pageSizeWidth, height: pageSizeHeight))
            }
        }
        // ぴったりページが終わっていたらそのまま抜ける
        guard pdfEntities.count % 8 != 0 else { return pdfViews }
        // 最後のページを詰める
        pdfViews.append(pdfView)
        return pdfViews
    }
    
    /// データを6個ずつ分けてUIViewを生成
    private func create6CellsPDFViews(pageSize: String) -> [UIView] {
        let pdfEntities = DiaryLayoutManager.shared.pdfEntities
        let pageSizeWidth = preparePageSizeWidth(pageSize: pageSize)
        let pageSizeHeight = preparePageSizeHeight(pageSize: pageSize)
        var pdfViews = [UIView]()
        var pdfView = UIView(frame: CGRect(x: 0, y: 0, width: pageSizeWidth, height: pageSizeHeight))
        var x = widthMargin
        var y = heightMargin
        for i in 0..<pdfEntities.count {
            x = i % 2 == 0 ? widthMargin : pageSizeWidth/2 // 偶数回の時は左、奇数回の時は右に位置
            if i % 6 == 0 {
                y = heightMargin // ページの一段目
            } else {
                y += i % 2 == 0 ? (pageSizeHeight-heightMargin*2)/3 : 0 // ページの2~3段目、偶数回目の時、次の段にいく
            }
            
            let frame = CGRect(x: x, y: y, width: pageSizeWidth/2-widthMargin, height: (pageSizeHeight-heightMargin*2)/3)
            
            if pdfEntities[i].image != nil {
                // 写真
                let picView = UINib(nibName: "PictureView", bundle: Bundle(for: type(of: self))).instantiate(withOwner: nil, options: nil).first as! PictureView
                picView.frame = frame
                picView.setup(diaryEntity: pdfEntities[i])
                picView.setupFrame(width: pageSizeWidth/2-widthMargin, height: (pageSizeHeight-heightMargin*2)/3)
                pdfView.addSubview(picView)
            }
            if !pdfEntities[i].diary.isEmpty {
                // 日記
                let diaryView = UINib(nibName: "DiaryView", bundle: Bundle(for: type(of: self))).instantiate(withOwner: nil, options: nil).first as! DiaryView
                diaryView.frame = frame
                diaryView.setup(diaryEntity: pdfEntities[i])
                diaryView.setupFrame(width: pageSizeWidth/2 - widthMargin, height: (pageSizeHeight-heightMargin*2)/3)
                pdfView.addSubview(diaryView)
            }
            // 6回分描写したら次のページへ進む
            if i % 6 == 5 {
                pdfViews.append(pdfView)
                // 初期化
                x = widthMargin
                y = heightMargin
                pdfView = UIView(frame: CGRect(x: 0, y: 0, width: pageSizeWidth, height: pageSizeHeight))
            }
        }
        // ぴったりページが終わっていたらそのまま抜ける
        guard pdfEntities.count % 6 != 0 else { return pdfViews }
        // 最後のページを詰める
        pdfViews.append(pdfView)
        return pdfViews
    }
    
    private func preparePageSizeWidth(pageSize: String) -> CGFloat {
        switch pageSize {
        case "B5":
            return b5Width
        case "A4":
            return a4Width
        case "A5":
            return a5Width
        default:
            return 0
        }
    }
    
    private func preparePageSizeHeight(pageSize: String) -> CGFloat {
        switch pageSize {
        case "B5":
            return b5Height
        case "A4":
            return a4Height
        case "A5":
            return a5Height
        default:
            return 0
        }
    }
}
