//
//  EditTextModalViewController.swift
//  albumdiary
//
//  Created by nonakashiho on 2022/02/19.
//

import UIKit

final class EditTextModalViewController: UIViewController {
    
    var context = ""
    var isEditTitle = true
    private var maxWordCount = 20 //最大文字数
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var alertTextLabel: UILabel!
    @IBOutlet private weak var completeButton: UIButton!
    @IBOutlet private weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        maxWordCount = isEditTitle ? 20 : 200 // タイトルは最大20字、日記は最大200字
        titleLabel.text = isEditTitle ? "タイトル" : "日記"
        textView.text = context
        textView.delegate = self
    }

    
    @IBAction func tapCompleteButton(_ sender: Any) {
        guard let naviVC = self.presentingViewController as? UINavigationController,
              let prevVC = naviVC.topViewController as? AddDiaryViewController else { return }
        // ラベルを更新
        dismiss(animated: true) {
            if self.isEditTitle {
                prevVC.updateTitleLabel(context: self.textView.text)
            } else {
                prevVC.updateDiaryContextLabel(context: self.textView.text)
            }
        }
    }
}

extension EditTextModalViewController: UITextViewDelegate {
    /// 文字数制限
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.text.count + (text.count - range.length) <= maxWordCount
    }
    
    /// 最大文字数を超えたら警告
    func textViewDidChange(_ textView: UITextView) {
        if maxWordCount - textView.text.count <= 0 {
            alertTextLabel.text = "最大\(maxWordCount)字です"
            alertTextLabel.isHidden = false
            completeButton.backgroundColor = .systemPink
            completeButton.setTitle("×", for: .normal)
            completeButton.isEnabled = false
        } else {
            // 通常
            alertTextLabel.isHidden = true
            completeButton.backgroundColor = .systemGreen
            completeButton.setTitle("投稿", for: .normal)
            completeButton.isEnabled = true
        }
    }
}
