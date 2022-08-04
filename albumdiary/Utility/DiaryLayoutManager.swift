//
//  DiaryLayoutManager.swift
//  albumdiary
//
//  Created by nonakashiho on 2022/05/01.
//

import UIKit

final class DiaryLayoutManager {
    
    static let shared = DiaryLayoutManager()
    // PDFのセル情報
    var pdfEntities = [DiaryEntity]()
    
    ///
    func preparePDFContents(fromDate: Date, numberOfSheets: Int, pageSize: String) {
        // 初期化
        pdfEntities = []
        // realmから範囲の日記を取り出す
        let tmpDiaryEntities = RealmUtility().searchDiary(fromDate: fromDate, toDate: Date())
        
        let cellCount = pageSize == "A5" ? 6 : 8
        
        // 一つのentityを写真組と日記組に分けて詰める
        for entity in tmpDiaryEntities {
            // 写真があれば追加
            if entity.image != nil {
                let tmpPDFDiary = DiaryEntity()
                tmpPDFDiary.date = entity.date
                tmpPDFDiary.image = entity.image
                tmpPDFDiary.rotate = entity.rotate
                tmpPDFDiary.title = entity.title
                pdfEntities.append(tmpPDFDiary)
            }
            // シート枚数分貯まったら抜ける
            if pdfEntities.count == cellCount*numberOfSheets {
                return
            }
            
            // 日記があれば追加
            if !entity.diary.isEmpty {
                let tmpPDFDiary = DiaryEntity()
                tmpPDFDiary.date = entity.date
                tmpPDFDiary.diary = entity.diary
                pdfEntities.append(tmpPDFDiary)
            }
            
            // シート枚数分貯まったら抜ける
            if pdfEntities.count == cellCount*numberOfSheets {
                return
            }
        }
    }
}
