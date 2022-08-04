//
//  CarouselCollectionViewCell.swift
//  albumdiary
//
//  Created by nonakashiho on 2022/06/10.
//

import UIKit

final class CarouselCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var postDiaryButton: UIButton!
    @IBOutlet private weak var editDiaryButton: UIButton!
    @IBOutlet private weak var deleteDiaryButton: UIButton!
    @IBOutlet private weak var photoImaveView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var diaryLabel: UILabel!
    
    private var targetEntity: DiaryEntity?
    var delegate: DiaryDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup(targetDate: Date, targetEntity: DiaryEntity?) {
        dateLabel.text = CalenderUtility().makeDateText(date: targetDate)
        if let image = targetEntity?.image {
            photoImaveView.image = image
            photoImaveView.isHidden = false
        } else {
            photoImaveView.isHidden = true
        }
        titleLabel.text = targetEntity?.title
        diaryLabel.text = targetEntity?.diary
        // 画像を回転
        let angle = CGFloat((targetEntity?.rotate ?? 0) * 90) * .pi / 180
        photoImaveView.transform = CGAffineTransform(rotationAngle: angle)
        
        changeButtonState(isEmpty: targetEntity == nil)
    }
    
    /// ボタン群の初期化
    /// - Parameter isExist: 日記が存在する
    private func changeButtonState(isEmpty: Bool) {
        postDiaryButton.isHidden = !isEmpty // 日記がない時は表示
        editDiaryButton.isHidden = isEmpty // 日記がない時は非表示
        deleteDiaryButton.isHidden = isEmpty // 日記がない時は非表示
    }
    
    /// "日記作成"ボタンが押された時の処理
    @IBAction func tapPostDiary(_ sender: Any) {
        delegate?.postDiary()
    }
    
    // "編集"ボタンが押された時の処理
    @IBAction func tapEditDiary(_ sender: Any) {
        delegate?.editDiary()
    }
    
    // "削除"ボタンが押された時の処理
    @IBAction func tapDeleteDiary(_ sender: Any) {
        delegate?.deleteDiary()
    }

}
