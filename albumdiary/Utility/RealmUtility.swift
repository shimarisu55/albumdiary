//
//  RealmUtility.swift
//  albumdiary
//
//  Created by nonakashiho on 2022/05/20.
//

import Foundation
import RealmSwift

final class RealmUtility {
    // 日記検索(一個。その対象日に日記が存在するか）
    func searchDiary(targetDate: Date) -> DiaryEntity? {
        let realm: Realm
        do {
            realm = try Realm()
            let predicate = CalenderUtility().makeFromDateToDatePredicate(fromDate: targetDate, toDate: targetDate)
            guard let targetEntity = realm.objects(DiaryEntity.self).filter(predicate).last else { return nil }
            // 現在のアカウントの日記のみに絞る
            guard judgeWhetherCurrentAcount(targetEntity: targetEntity) else { return nil }
            return targetEntity
        } catch {
            return nil
        }
    }
    
    /// 対象一日の日記を複数取り出す
    /// - Parameter targetDate: 対象日
    /// - Returns: 日記リスト
    func searchOneDayDiaries(targetDate: Date) -> [DiaryEntity] {
        let realm: Realm
        do {
            realm = try Realm()
            let predicate = CalenderUtility().makeFromDateToDatePredicate(fromDate: targetDate, toDate: targetDate)
            let targetEntities = Array(realm.objects(DiaryEntity.self).filter(predicate))
            // 現在のアカウントの日記のみに絞る
            let filteredResults = filterWithAcount(entities: targetEntities)
            filteredResults.forEach { entity in
                // 複数の写真を取り出し、時系列順にentityに付
                entity.image = searchImage(targetEntity: entity)
            }
            return filteredResults
        } catch {
            return []
        }
    }
    
    /// 日付をキーにrealmから検索
    func searchDiary(fromDate: Date, toDate: Date) -> [DiaryEntity] {
        // realmでdateをキーに検索
        let realm: Realm
        do {
            realm = try Realm()
            let predicate = CalenderUtility().makeFromDateToDatePredicate(fromDate: fromDate, toDate: toDate)
            let results = realm.objects(DiaryEntity.self).filter(predicate)
            var tmpEntities = [DiaryEntity]()
            // データを第一に日付順、同じ日付の時はserial番号順に並べ替える
            let sortedResults = results.sorted(by: {
                if $0.date == $1.date { return $0.serialNumber < $1.serialNumber }
                else {
                    return $0.date < $1.date
                }
            })
            // 現在のアカウントの日記のみに絞る
            let filteredResults = filterWithAcount(entities: sortedResults)
            for entity in filteredResults {
                // 写真があれば追加
                if let diaryImage = searchImage(targetEntity: entity) {
                    entity.image = diaryImage
                }
                tmpEntities.append(entity)
            }
            return tmpEntities
        } catch {
            return []
        }
    }
    
    // 日記作成
    func postDiary(targetEntity: DiaryEntity, rotate: Int, title: String, diaryText: String) {
        // 保存するものがなければreturn
        guard !title.isEmpty || !diaryText.isEmpty || targetEntity.image != nil else { return }
        targetEntity.serialNumber = countSerialNumberPerOneDay(targetDate: targetEntity.date)
        guard let fileURL = prepareImageFileUrl(isCreate: true, targetEntity: targetEntity) else { return }
        targetEntity.photoImageURL = fileURL.absoluteString
        targetEntity.rotate = rotate
        targetEntity.diary = diaryText
        targetEntity.title = title
        targetEntity.acount = UserDefaultUtility().getAcountSetting()
        let realm: Realm
        do {
            realm = try Realm()
            // 画像をdocumentに保存
            saveImage(fileURL: fileURL, targetEntity: targetEntity)
            try realm.write {
                realm.add(targetEntity)
            }
        } catch {
            return
        }
    }
    
    // 日記更新
    func updateDiary(targetEntity: DiaryEntity, rotate: Int, title: String, diaryText: String) {
        // 保存するものがなければentityごと削除
        guard !title.isEmpty || !diaryText.isEmpty || targetEntity.image != nil else {
            deleteDiary(targetEntity: targetEntity)
            return
        }
        guard let fileURL = prepareImageFileUrl(isCreate: true, targetEntity: targetEntity) else { return }
        let realm: Realm
        do {
            realm = try Realm()
            // 画像をdocumentに保存
            saveImage(fileURL: fileURL, targetEntity: targetEntity)
            try realm.write {
                targetEntity.rotate = rotate
                targetEntity.title = title
                targetEntity.diary = diaryText
            }
        } catch {
            return
        }
    }
    
    // 写真とタイトルを削除
    func deleteImageAndTitle(targetEntity: DiaryEntity) {
        // 写真とタイトルを削除
        guard let fileURL = prepareImageFileUrl(isCreate: true, targetEntity: targetEntity) else { return }
        let realm: Realm
        do {
            realm = try Realm()
            deleteImage(fileURL: fileURL, targetEntity: targetEntity)
            try realm.write {
                targetEntity.rotate = 0
                targetEntity.title = ""
                targetEntity.photoImageURL = ""
            }
        } catch {
            return
        }
    }
    
    // 日記削除
    func deleteDiary(targetEntity: DiaryEntity) {
        guard let fileURL = prepareImageFileUrl(isCreate: false, targetEntity: targetEntity) else { return }
        let realm: Realm
        do {
            realm = try Realm()
            deleteImage(fileURL: fileURL, targetEntity: targetEntity)
            try realm.write {
                realm.delete(targetEntity)
            }
        } catch {
            return
        }
    }
    
    // アカウントの日記をすべて削除
    func deleteAllDiary(targetAcount: String) {
        let realm: Realm
        do {
            realm = try Realm()
            let predicate = NSPredicate(format: "acount = %@", argumentArray: [targetAcount])
            let results = realm.objects(DiaryEntity.self).filter(predicate)
            results.forEach { entity in
                deleteDiary(targetEntity: entity)
            }
        } catch {
            return
        }
    }
    
    // MARK: - 写真をdocumentに保存
    
    // 画像の読み出し
    func searchImage(targetEntity: DiaryEntity) -> UIImage? {
        guard let fileURL = prepareImageFileUrl(isCreate: false, targetEntity: targetEntity) else { return nil }
        do {
            let readData = try Data(contentsOf: fileURL)
            return UIImage(data: readData)
        } catch let error {
            print(error)
        }
        return nil
    }
    
    // 画像ファイルのurlを用意
    private func prepareImageFileUrl(isCreate: Bool, targetEntity: DiaryEntity) -> URL? {
        // uuid付きのファイルのurl
        guard let url = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: isCreate) else { return nil }
        let savedDateString = CalenderUtility().makeSavedDateText(date: targetEntity.date)
        let picSerialNum = targetEntity.serialNumber.description
        let fileName = "\(savedDateString)-\(picSerialNum).jpeg"
        let path = url.appendingPathComponent(fileName)
        return path
    }
    
    //画像を保存/更新
    private func saveImage(fileURL: URL, targetEntity: DiaryEntity) {
        guard let image = targetEntity.image else { return }
        // jpegで保存する場合
        let jpegImageData = image.jpegData(compressionQuality: 0.5)
        do {
            try jpegImageData?.write(to: fileURL)
        } catch let error {
            print(error)
        }
    }
    
    // 画像を削除
    private func deleteImage(fileURL: URL, targetEntity: DiaryEntity) {
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch let error {
            print(error)
        }
    }
    
    // 一日のうちの最大の連番数を返す
    private func countSerialNumberPerOneDay(targetDate: Date) -> Int {
        let initialNumber = 1
        let realm: Realm
        do {
            realm = try Realm()
            let predicate = CalenderUtility().makeFromDateToDatePredicate(fromDate: targetDate, toDate: targetDate)
            let entities = realm.objects(DiaryEntity.self).filter(predicate)
            // その日のentityのうち、写真の連番が最大の数を返す
            let maxSerialNumber = Array(entities).max(by: { (a, b) -> Bool in
                return a.serialNumber < b.serialNumber
            })
            return (maxSerialNumber?.serialNumber ?? 0) + initialNumber
        } catch {
            return initialNumber
        }
        
    }
    
    // MARK: - アカウントフィルター（現在使っているアカウントの日記のみ）
    
    /// 対象の日記が現在のアカウントの日記かどうかを調べる
    /// - Parameter targetEntity: 対象の日記
    /// - Returns: true/false
    private func judgeWhetherCurrentAcount(targetEntity: DiaryEntity) -> Bool {
        let currentAcount = UserDefaultUtility().getAcountSetting()
        return targetEntity.acount == currentAcount
    }
    
    /// 日記リストから現在設定しているアカウントの日記のみ抽出
    /// - Parameter entities: 日記リスト
    /// - Returns: フィルター済みの日記リスト
    private func filterWithAcount(entities: [DiaryEntity]) -> [DiaryEntity] {
        let currentAcount = UserDefaultUtility().getAcountSetting()
        let result = entities.filter { entity in
            entity.acount == currentAcount
        }
        return result
    }
}
