//
//  DiaryEntity.swift
//  albumdiary
//
//  Created by nonakashiho on 2022/02/19.
//

import Foundation
import RealmSwift

class DiaryEntity: Object {
    @objc dynamic var acount = "デフォルト"
    @objc dynamic var date = Date()
    @objc dynamic var title = ""
    @objc dynamic var diary = ""
    @objc dynamic var englishDiary = ""
    @objc dynamic var englishF = false
    @objc dynamic var rotate = 0
    @objc dynamic var photoImageURL = ""
    @objc dynamic var serialNumber = 0
    var image: UIImage? = nil

}
