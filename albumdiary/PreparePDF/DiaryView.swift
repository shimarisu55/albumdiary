//
//  DiaryView.swift
//  albumdiary
//
//  Created by nonakashiho on 2022/05/29.
//

import UIKit

class DiaryView: UIView {
    
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var diaryLabel: UILabel!
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func prepareForInterfaceBuilder() {
    }
    
    func setup(diaryEntity: DiaryEntity) {
        let dateString = CalenderUtility().makeDateText(date: diaryEntity.date)
        dateLabel.text = dateString
        diaryLabel.text = diaryEntity.diary
    }
    
    func setupFrame(width: CGFloat, height: CGFloat) {
        let dateFrame = CGRect(x: 10, y: 2, width: width-20, height: 11)
        dateLabel.frame = dateFrame
        let diaryFrame = CGRect(x: 10, y: 13, width: width-20, height: height-15)
        diaryLabel.frame = diaryFrame
        diaryLabel.sizeToFit()
    }
}
