//
//  SettingViewController.swift
//  albumdiary
//
//  Created by nonakashiho on 2022/06/28.
//

import UIKit

enum SettingSection: Int, CaseIterable {
    case acount
    case printCount
    case debug
}

final class SettingViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    private var acountList = UserDefaultUtility().getAcountList()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
        tableView.isEditing = editing
    }
    
    private func showAlert(title: String, confirm: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message:  "", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "はい", style: .default) { _ in
            confirm()
            self.dismiss(animated: true)
        }
        // キャンセルボタンの処理
        let cancelAction = UIAlertAction(title: "いいえ", style: .cancel, handler:{ _ in
            self.dismiss(animated: true)
        })
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        present(alert, animated: true, completion: nil)
    }
}

extension SettingViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
//        #if DEBUG
//        return 3
//        #endif
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SettingSection.acount.rawValue:
            // アカウントは5つまで
            return acountList.count >= 5 ? acountList.count : acountList.count + 1
        case SettingSection.printCount.rawValue:
            return UserDefaultUtility().isEndFirstTrialTime() ? 5 : 1
        case SettingSection.debug.rawValue:
            return 3
        default:
            return 0 // こない想定
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
            
        case SettingSection.acount.rawValue:
            let cell = UITableViewCell()
            if indexPath.row == acountList.count {
                // 最後のセル
                cell.textLabel?.text = "新しく追加"
                return cell
            }
            cell.textLabel?.text = "\(acountList[indexPath.row])"
            // 現在のアカウント名だった時はチェックをつける
            let currentAcountName = UserDefaultUtility().getAcountSetting()
            if acountList[indexPath.row] == currentAcountName {
                cell.accessoryType = .checkmark
            }
            return cell
        case SettingSection.printCount.rawValue:
            let cell = UITableViewCell()
            switch indexPath.row {
            case 0:
                if UserDefaultUtility().isEndFirstTrialTime() {
                    // 通常
                    let freePrintCount = UserDefaultUtility().freePrintCountPerMonth()
                    cell.textLabel?.text = "今月の無料印刷枚数：　\(freePrintCount)"
                } else {
                    // 試用期間中
                    cell.textLabel?.text = "試用期間中"
                }
                return cell
            case 1:
                let paidPrintCount = UserDefaultUtility().paidPrintCount()
                cell.textLabel?.text = "課金済み印刷枚数：　\(paidPrintCount)"
                return cell
            case 2:
                let isSubscription = UserDefaultUtility().isSubscription() ? "済み" : "未"
                cell.textLabel?.text = "サブスクリプション購入：　\(isSubscription)"
                return cell
            case 3:
                cell.textLabel?.text = "印刷枚数を購入"
                return cell
            default:
                cell.textLabel?.text = "印刷枚数を復元"
                return cell
            }
        case SettingSection.debug.rawValue:
            let cell = UITableViewCell()
            switch indexPath.row {
            case 0:
                let cunsumedFirstFreePrintCount = UserDefaultUtility().getExportPDFSheets()
                cell.textLabel?.text = "試用期間中の印刷消費枚数： \(cunsumedFirstFreePrintCount)"
                return cell
            case 1:
                guard let updateDate = UserDefaultUtility().updateDateFreePrintCountPerMonth() else {
                    cell.textLabel?.text = "無料印刷枚数リセット更新日： なし"
                    return cell }
                let updateDateString = CalenderUtility().makeDateText(date: updateDate)
                cell.textLabel?.text = "無料印刷枚数リセット更新日： \(updateDateString)"
                return cell
            default:
                cell.textLabel?.text = "今月の無料印刷枚数を増やす"
                return cell
            }
        default:
            return UITableViewCell() // こない想定
        }
    }
    
    // セルの選択状態を拒否
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case SettingSection.acount.rawValue:
            return true
        case SettingSection.printCount.rawValue:
            return indexPath.row == 3 || indexPath.row == 4
        case SettingSection.debug.rawValue:
            return indexPath.row == 2
        default:
            return false // 来ない想定
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case SettingSection.acount.rawValue:
            if indexPath.row == acountList.count {
                // 最後のセル/新しく追加
                let modalVC = AddAcountNameViewController()
                modalVC.modalPresentationStyle = .automatic
                modalVC.presentationController?.delegate = self
                present(modalVC, animated: true, completion: nil)
            }
            showAlert(title: "アカウントを切り替えますか？") {
                UserDefaultUtility().setAcountSetting(acountName: "\(self.acountList[indexPath.row])")
                tableView.reloadData()
            }
        case SettingSection.printCount.rawValue:
            if indexPath.row == 3 {
                // 課金ページへ
                let nextPage = PayPromotionViewController()
                present(nextPage, animated: true)
                return
            } else if indexPath.row == 4 {
                // 復元アラート
                showAlert(title: "古い端末でサブスクリプションを購入していた場合、復元することができます。復元しますか？") {
                    StoreKitManager.shared.restoreSubscription()
                }
            }
            return
        case SettingSection.debug.rawValue:
            if indexPath.row == 2 {
                UserDefaultUtility().setFreePrintCountPerMonth()
                tableView.reloadData()
            }
            return
        default:
            return // こない想定
        }
    }
    
    //セルの削除許可を設定
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool{
        switch indexPath.section {
        case SettingSection.acount.rawValue:
            return true
        default:
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case SettingSection.acount.rawValue:
            if editingStyle == .delete {
                showAlert(title: "本当にこのアカウントのデータをすべて消しますか？") {
                    UserDefaultUtility().deleteAcount(acountName: self.acountList[indexPath.row])
                    self.acountList = UserDefaultUtility().getAcountList()
                    tableView.reloadData()
                }
            }
        default:
            return
        }
    }
}

extension SettingViewController: UITableViewDelegate {
    // ヘッダー
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case SettingSection.acount.rawValue:
            return "アカウント切り替え"
        case SettingSection.printCount.rawValue:
            return "残り印刷枠"
        case SettingSection.debug.rawValue:
            return "デバッグ機能"
        default:
            return "" // こない想定
        }
    }
}

extension SettingViewController: UIAdaptivePresentationControllerDelegate {
  func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
      // モーダルの dismiss を検知
      acountList = UserDefaultUtility().getAcountList()
      tableView.reloadData()
  }
}
