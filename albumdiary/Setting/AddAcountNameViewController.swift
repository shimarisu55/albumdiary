//
//  AddAcountNameViewController.swift
//  albumdiary
//
//  Created by nonakashiho on 2022/06/30.
//

import UIKit

final class AddAcountNameViewController: UIViewController {

    private var maxWordCount = 10 //最大文字数
    
    @IBOutlet private weak var alertTextLabel: UILabel!
    @IBOutlet private weak var completeButton: UIButton!
    @IBOutlet private weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
//    
//    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
//        super.dismiss(animated: flag, completion: completion)
//        guard let presentationController = presentationController else {
//            return
//        }
//        presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
//    }

    
    @IBAction func tapCompleteButton(_ sender: Any) {
        guard let presentationController = presentationController else {
            return
        }
        // ラベルを更新
        dismiss(animated: true) {
            UserDefaultUtility().addAcountList(accountName: self.textView.text)
            presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
        }
    }

}

extension AddAcountNameViewController: UITextViewDelegate {
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
            completeButton.setTitle("追加", for: .normal)
            completeButton.isEnabled = true
        }
    }
}
