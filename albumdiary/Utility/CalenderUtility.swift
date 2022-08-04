//
//  CalenderUtility.swift
//  albumdiary
//
//  Created by nonakashiho on 2022/02/20.
//

import Foundation

class CalenderUtility {
    
    /// いつからいつまで、という条件を生成
    func makeFromDateToDatePredicate(fromDate: Date, toDate: Date) -> NSPredicate {
        // その日の日付一日を検索
        var fromComponent = NSCalendar.current.dateComponents([.year, .month, .day], from: fromDate)
        fromComponent.hour = 0
        fromComponent.minute = 0
        fromComponent.second = 0
        let start = NSCalendar.current.date(from:fromComponent)! as NSDate
        var toComponent = NSCalendar.current.dateComponents([.year, .month, .day], from: toDate)
        toComponent.hour = 23
        toComponent.minute = 59
        toComponent.second = 59
        let end = NSCalendar.current.date(from:toComponent)! as NSDate
        return NSPredicate(format:"(date >= %@) AND (date <= %@)", start, end)
    }
    
    /// 日付をyyyy/MM/ddの文字列で表示
    func makeDateText(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy/MM/dd(EEE)"
        return dateFormatter.string(from: date)
    }
    
    /// 日付をyyyyMMddの文字列で表示
    func makeSavedDateText(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter.string(from: date)
    }
}
