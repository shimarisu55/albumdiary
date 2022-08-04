//
//  AddDiaryViewController.swift
//  albumdiary
//
//  Created by nonakashiho on 2022/05/29.
//

import UIKit
import Photos

final class AddDiaryViewController: UIViewController {
    
    var targetEntity: DiaryEntity?
    // 新規作成(true）か、編集(false)か
    var isNewCreate = false
    // 画像の回転
    var rotate = 0
    
    @IBOutlet private weak var dateLabel: UILabel!
    // 写真
    @IBOutlet private weak var rotateImageButton: UIButton!
    @IBOutlet private weak var deleteImageButton: UIButton!
    @IBOutlet private weak var imageView: UIImageView!
    // タイトル
    @IBOutlet private weak var titleStackView: UIStackView!
    @IBOutlet private weak var postTitleButton: UIButton!
    @IBOutlet private weak var deleteTitleButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    // 日記
    @IBOutlet private weak var postDiaryButton: UIButton!
    @IBOutlet private weak var deleteDiaryButton: UIButton!
    @IBOutlet private weak var diaryLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupToolBar()
        setup()
    }
    
    // "作成"ボタンが押された時の処理
    @objc func postButtonTapped(_ sender: UIBarButtonItem) {
        guard let entity = targetEntity else { return }
        if isNewCreate {
            // 新しく作成
            RealmUtility().postDiary(targetEntity: entity, rotate: rotate, title: titleLabel.text ?? "", diaryText: diaryLabel.text ?? "")
        } else {
            // 更新
            RealmUtility().updateDiary(targetEntity: entity, rotate: rotate, title: titleLabel.text ?? "", diaryText: diaryLabel.text ?? "")
        }
        navigationController?.popToRootViewController(animated: true)
    }
    
    // モーダルで入力したタイトルの文章を反映
    func updateTitleLabel(context: String) {
        guard !context.isEmpty else { return } // ""だった場合は何もしない
        titleLabel.text = context
        titleLabel.isHidden = false
        postTitleButton.setTitle("編集", for: .normal)
        deleteTitleButton.isHidden = false
    }
    // モーダルで入力した日記の文章を反映
    func updateDiaryContextLabel(context: String) {
        guard !context.isEmpty else { return } // ""だった場合は何もしない
        diaryLabel.text = context
        diaryLabel.isHidden = false
        postDiaryButton.setTitle("編集", for: .normal)
        deleteDiaryButton.isHidden = false
    }
    
    private func setupToolBar() {
        let topLabelText = isNewCreate ? "新規作成" : "編集"
        navigationItem.title = topLabelText
        // 日記作成
        let postDiaryButtonItem = UIBarButtonItem(title: "作成", style: .done, target: self, action: #selector(postButtonTapped(_:)))
        navigationItem.rightBarButtonItems = [postDiaryButtonItem]
    }
    
    private func setup() {
        let targetDate = targetEntity?.date ?? Date()
        dateLabel.text = CalenderUtility().makeDateText(date: targetDate)
        // 写真があったら表示
        if let image = targetEntity?.image {
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
            changePictureStatus(isExistPicture: true)
        }
        // 写真を回転するか
        if let rotateInt = targetEntity?.rotate, rotateInt != 0 {
            rotate = rotateInt
            imageView.transform = CGAffineTransform(rotationAngle: CGFloat(rotateInt * 90) * .pi / 180)
        }
        // タイトルがあったら表示
        if let title = targetEntity?.title, !title.isEmpty {
            titleLabel.text = title
            titleLabel.isHidden = false
            postTitleButton.setTitle("編集", for: .normal)
            deleteTitleButton.isHidden = false
        }
        // 日記があったら表示
        if let diary = targetEntity?.diary, !diary.isEmpty {
            diaryLabel.text = diary
            diaryLabel.isHidden = false
            postDiaryButton.setTitle("編集", for: .normal)
            deleteDiaryButton.isHidden = false
        }
    }
    
    /// 写真を追加したら回転ボタン、削除ボタン、タイトル編集を追加
    /// - Parameter isExistPicture: 写真を追加
    private func changePictureStatus(isExistPicture: Bool) {
        imageView.isHidden = !isExistPicture
        rotateImageButton.isHidden = !isExistPicture
        deleteImageButton.isHidden = !isExistPicture
        titleStackView.isHidden = !isExistPicture
    }
    
    /// iOS11以降のフォトライブラリへのアクセス許可アラートが表示されないので自前で実装
    private func albumCommonAction(_ authorizationStatus: PHAuthorizationStatus) {
        // フォトライブラリを使う準備
        let photoLibraryPicker = UIImagePickerController()
        photoLibraryPicker.sourceType = .photoLibrary
        photoLibraryPicker.delegate = self

        switch authorizationStatus {
        case .notDetermined:
            // 初回起動時アルバムアクセス権限確認
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                    case .authorized:
                        // アクセスを許可するとカメラロールが出てくる
                        DispatchQueue.main.async {
                            self.present(photoLibraryPicker, animated: true)
                        }
                    default:
                        break
                }
            }
        case .denied, .limited:
            // アクセス権限がないとき
            let alert = UIAlertController(title: "すべての写真へのアクセスを許可してください", message: "", preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: "設定", style: .default, handler: { (_) -> Void in
                guard let settingsURL = URL(string: UIApplication.openSettingsURLString ) else {
                    return
                }
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
             })
            let closeAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
            alert.addAction(settingsAction)
            alert.addAction(closeAction)
            self.present(alert, animated: true, completion: nil)
        case .authorized, .restricted:
            // アクセス権限があるとき
            self.present(photoLibraryPicker, animated: true)
        @unknown default:
            break
        }
    }
    
    @IBAction func rotatePhoto(_ sender: Any) {
        rotate -= 1
        imageView.transform = CGAffineTransform(rotationAngle: CGFloat(rotate * 90) * .pi / 180)
    }
    
    // カメラを起動して写真を撮る
    @IBAction func takePhoto(_ sender: Any) {
        let sourceType = UIImagePickerController.SourceType.camera
        // カメラが利用可能かチェック
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            // インスタンスの作成
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            present(cameraPicker, animated: true, completion: nil)
        }
    }
    
    // 既存の写真から選ぶ
    @IBAction func managePhoto(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            albumCommonAction(authorizationStatus)
        }
    }
    
    // 写真とタイトルを削除
    @IBAction func deletePhoto(_ sender: Any) {
        let alert = UIAlertController(title: "写真とタイトルを消しますか？", message:  "", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "はい", style: .default, handler:{ _ in
            guard let entity = self.targetEntity else { return }
            entity.image = nil
            RealmUtility().deleteImageAndTitle(targetEntity: entity)
            self.changePictureStatus(isExistPicture: false)
            // 写真が削除されたらタイトルも削除
            self.titleLabel.text = ""
            self.dismiss(animated: true)
        })
        // キャンセルボタンの処理
        let cancelAction = UIAlertAction(title: "いいえ", style: .cancel, handler:{ _ in
            self.dismiss(animated: true)
        })
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    
    @IBAction func addTitle(_ sender: Any) {
        let modalVC = EditTextModalViewController()
        let titleText = targetEntity?.title ?? ""
        modalVC.context = titleLabel.text ?? titleText
        modalVC.modalPresentationStyle = .custom
        modalVC.transitioningDelegate = self
        present(modalVC, animated: true, completion: nil)
    }
    
    @IBAction func removeTitle(_ sender: Any) {
        titleLabel.text = ""
        deleteTitleButton.isHidden = true
        postTitleButton.setTitle("追加", for: .normal)
    }
    
    @IBAction func addDiary(_ sender: Any) {
        // タップ後日記本文を修正する。
        let modalVC = EditTextModalViewController()
        modalVC.isEditTitle = false
        let diaryText = targetEntity?.diary ?? ""
        modalVC.context = diaryLabel.text ?? diaryText
        modalVC.modalPresentationStyle = .custom
        modalVC.transitioningDelegate = self
        present(modalVC, animated: true, completion: nil)
    }
    
    @IBAction func removeDiary(_ sender: Any) {
        diaryLabel.text = ""
        deleteDiaryButton.isHidden = true
        postDiaryButton.setTitle("追加", for: .normal)
    }
    
}

extension AddDiaryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //　撮影が完了時した時に呼ばれる
    func imagePickerController(_ imagePicker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        
        if let pickedImage = info[.originalImage] as? UIImage {
            imageView.contentMode = .scaleAspectFit
            rotate = 0
            imageView.transform = CGAffineTransform(rotationAngle: CGFloat(rotate * 90) * .pi / 180)
            imageView.image = pickedImage
            targetEntity?.image = pickedImage
            changePictureStatus(isExistPicture: true)
        }
        //閉じる処理
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    // 撮影がキャンセルされた時に呼ばれる
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// 日記を書くモーダルをポップアップ表示
extension AddDiaryViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PresentationController(presentedViewController: presented, presenting: presenting)
    }
}

