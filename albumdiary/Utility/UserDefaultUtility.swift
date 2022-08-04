//
//  UserDefaultUtility.swift
//  albumdiary
//
//  Created by nonakashiho on 2022/06/05.
//

import Foundation

final class UserDefaultUtility {
    
    /// 出力したPDFの枚数を保存
    func setExportPDFSheets(sheetNumber: Int) {
        var newSheetsNumber = getExportPDFSheets()
        newSheetsNumber += sheetNumber
        UserDefaults.standard.set(newSheetsNumber, forKey: "ExportPDFSheetNumber")
    }
    
    /// 今まで出力したPDFの枚数を取得
    func getExportPDFSheets() -> Int {
        UserDefaults.standard.integer(forKey: "ExportPDFSheetNumber")
    }
    
    // MARK: - 試用期間
    
    /// 試用期間の終了（最初の無料印刷枠20枚を使い切った合図)
    func setEndFirstTrialTime() {
        UserDefaults.standard.set(true, forKey: "EndFirstTrialTime")
    }
    
    /// 試用期間が終わっている場合trueを返す
    func isEndFirstTrialTime() -> Bool {
        UserDefaults.standard.bool(forKey: "EndFirstTrialTime")
    }
    
    // MARK: - 無料印刷枚数リセット更新日
    /// 無料印刷枚数を今月更新していたらtrueを返す
    func isUpdateDateFreePrintCountPerMonth() -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        // 現在の月を取得
        let todayMonth = calendar.component(.month, from: Date())
        // 更新日の月を取得
        guard let updateDate = updateDateFreePrintCountPerMonth() else { return false }
        let updateMonth = calendar.component(.month, from: updateDate)
        return todayMonth == updateMonth
    }
    
    /// 無料印刷枚数を10にセットした日付を返す
    func updateDateFreePrintCountPerMonth() -> Date? {
        guard let updateDate = UserDefaults.standard.object(forKey: "UpdateDateFreePrintCountPerMonth") as? Date else { return nil }
        return updateDate
    }
    
    // 無料印刷枚数更新日を「今日」に設定
    private func saveUpdateFreePrintCountPerMonth() {
        UserDefaults.standard.set(Date(), forKey: "UpdateDateFreePrintCountPerMonth")
    }
    
    // MARK: - 月の無料印刷枠
    /// 月の初めに無料印刷枚数を10にセットする
    func setFreePrintCountPerMonth() {
        UserDefaults.standard.set(10, forKey: "FreePrintCountPerMonth")
        // 更新日を保存
        saveUpdateFreePrintCountPerMonth()
    }
    
    /// 無料印刷枠を消費する時にカウントする。足りない時は有料印刷枠を消費
    func consumeFreePrintCountPerMonth(consumeCount: Int) {
        let currentFreePrintCount = freePrintCountPerMonth()
        if currentFreePrintCount - consumeCount >= 0 {
            UserDefaults.standard.set(currentFreePrintCount-consumeCount, forKey: "FreePrintCountPerMonth")
        } else {
            // 無料印刷枠が足りない場合は有料印刷枠を消費
            UserDefaults.standard.set(0, forKey: "FreePrintCountPerMonth")
            let consumePaidPrintCount = consumeCount - currentFreePrintCount
            consumePaidPrintCountPerMonth(consumeCount: consumePaidPrintCount)
        }
        
    }
    
    /// 今月の無料印刷枠数
    func freePrintCountPerMonth() -> Int {
        UserDefaults.standard.integer(forKey: "FreePrintCountPerMonth")
    }
    
    // MARK: - 有料印刷枠
    /// 課金後、有料印刷枠をセットする
    func setPaidPrintCount(count: Int) {
        let currentPaidPrintCount = paidPrintCount()
        UserDefaults.standard.set(currentPaidPrintCount+count, forKey: "PaidPrintCount")
    }
    
    /// 有料印刷枠を消費する時にカウントする
    func consumePaidPrintCountPerMonth(consumeCount: Int) {
        let currentPaidPrintCount = paidPrintCount()
        UserDefaults.standard.set(currentPaidPrintCount-consumeCount, forKey: "PaidPrintCount")
    }
    
    /// 有料印刷枠数を返す
    func paidPrintCount() -> Int {
        UserDefaults.standard.integer(forKey: "PaidPrintCount")
    }
    
    /// サブスクリプション購入後/期限切れ後セットする
    func setSubscription(isPaid: Bool) {
        UserDefaults.standard.set(isPaid, forKey: "SubscriptionOneMonth")
    }
    
    /// サブスクリプション期間中かを返す
    func isSubscription() -> Bool {
        UserDefaults.standard.bool(forKey: "SubscriptionOneMonth")
    }
    
    // MARK: - アカウント設定
    /// インストール時の初回設定
    func setupFirstLaunchAcountSetting() {
        // 最初の一回だけ
        guard !UserDefaults.standard.bool(forKey: "AlreadyFirstLaunch") else { return }
        addAcountList(accountName: "デフォルト")
        setAcountSetting(acountName: "デフォルト")
        UserDefaults.standard.set(true, forKey: "AlreadyFirstLaunch")
    }
    
    /// 現在のアカウント設定
    func setAcountSetting(acountName: String) {
        UserDefaults.standard.set(acountName, forKey: "AcountName")
    }
    
    /// 現在のアカウント設定参照
    func getAcountSetting() -> String {
        UserDefaults.standard.string(forKey: "AcountName") ?? "デフォルト"
    }
    
    /// アカウント追加
    func addAcountList(accountName: String) {
        guard !accountName.isEmpty else { return }
        var currentAcountList = getAcountList()
        currentAcountList.append(accountName)
        UserDefaults.standard.set(currentAcountList, forKey: "AcountList")
    }
    
    /// 現在持っているすべてのアカウントを表示
    func getAcountList() -> [String] {
        guard let acountList = UserDefaults.standard.array(forKey: "AcountList")
                as? [String] else { return [] }
        return acountList
    }
    
    /// 対象アカウントを削除
    func deleteAcount(acountName: String) {
        var currentAcountList = getAcountList()
        guard let acountIndex = currentAcountList.firstIndex(of: acountName) else { return }
        currentAcountList.remove(at: acountIndex)
        UserDefaults.standard.set(currentAcountList, forKey: "AcountList")
        // アカウントに紐づく投稿を削除
        RealmUtility().deleteAllDiary(targetAcount: acountName)
    }
}
