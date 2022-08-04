//
//  PictureView.swift
//  albumdiary
//
//  Created by nonakashiho on 2022/05/29.
//

import UIKit

class PictureView: UIView {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    
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
        imageView.image = diaryEntity.image
        // 写真を回転するか
        if diaryEntity.rotate != 0 {
            imageView.transform = CGAffineTransform(rotationAngle: CGFloat(diaryEntity.rotate * 90) * .pi / 180)
        }
        titleLabel.text = diaryEntity.title
    }
    
    func setupFrame(width: CGFloat, height: CGFloat) {
        // padding 縦2、横10
        let dateFrame = CGRect(x: 10, y: 2, width: width-20, height: 11)
        dateLabel.frame = dateFrame
        let imageFrame = CGRect(x: 10, y: 15, width: width-20, height: height-43)
        imageView.frame = imageFrame
        let diaryFrame = CGRect(x: 10, y: height-26, width: width-20, height: 24)
        titleLabel.frame = diaryFrame
    }
    

}
