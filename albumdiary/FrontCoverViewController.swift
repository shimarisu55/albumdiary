//
//  FrontCoverViewController.swift
//  albumdiary
//
//  Created by nonakashiho on 2021/12/05.
//

import UIKit
import FSCalendar

protocol DiaryDelegate {
    func postDiary()
    func editDiary()
    func deleteDiary()
}

final class FrontCoverViewController: UIViewController {
    
    @IBOutlet private weak var calenderView: FSCalendar!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    lazy private var targetDayDiaries = RealmUtility().searchOneDayDiaries(targetDate: targetDate)
    private var targetDate = Date()
    private var pageCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let settingButtonItem = UIBarButtonItem(title: "設定", style: .done, target: self, action: #selector(settingButtonTapped(_:)))
        navigationItem.leftBarButtonItems = [settingButtonItem]
        let pdfButtonItem = UIBarButtonItem(title: "PDF出力", style: .done, target: self, action: #selector(pdfButtonTapped(_:)))
        navigationItem.rightBarButtonItems = [pdfButtonItem]
        navigationController?.navigationBar.tintColor = UIColor(named: "Basic")
        
        // collectionViewセル登録
        let nib = UINib(nibName: "CarouselCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "CarouselCollectionViewCell")
        
        // 月の初めに無料印刷枚数をプレゼント
        // 試用期間が終わっている場合表示
        // すでに無料印刷枚数が10枚ではない場合（１枚以上消費していた場合）表示
        if !UserDefaultUtility().isUpdateDateFreePrintCountPerMonth(),
           UserDefaultUtility().isEndFirstTrialTime(),
           UserDefaultUtility().freePrintCountPerMonth() != 10 {
            let presentPage = PresentFreePrintCountPerMonthViewController()
            present(presentPage, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 投稿があれば表示
        targetDayDiaries = RealmUtility().searchOneDayDiaries(targetDate: targetDate)
        collectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        layout.itemSize = collectionView.bounds.size
        collectionView.collectionViewLayout = layout
    }
    
    // "設定"ボタンが押された時の処理
    @objc func settingButtonTapped(_ sender: UIBarButtonItem) {
        // カレンダーで出力範囲を選んだ後PDFに出力
        let nextPageVC = SettingViewController()
        navigationController?.pushViewController(nextPageVC, animated: true)
    }
    
    // "PDF出力"ボタンが押された時の処理
    @objc func pdfButtonTapped(_ sender: UIBarButtonItem) {
        // カレンダーで出力範囲を選んだ後PDFに出力
        let nextPageVC = ConfirmCalenderViewController()
        nextPageVC.selectedFromDate = targetDate
        navigationController?.pushViewController(nextPageVC, animated: true)
    }
    
}

extension FrontCoverViewController: FSCalendarDataSource,FSCalendarDelegate {
    
    /// 投稿がある日はマークをつける
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let results = RealmUtility().searchDiary(targetDate: date)
        return results != nil ? 1 : 0
    }
    
    /// カレンダーの日付を押すとその日の投稿を表示
    func calendar(_ calendar: FSCalendar,
                  didSelect date: Date,
                  at monthPosition: FSCalendarMonthPosition) {
        targetDate = date
        targetDayDiaries = RealmUtility().searchOneDayDiaries(targetDate: targetDate)
        collectionView.reloadData()
    }
}

extension FrontCoverViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return targetDayDiaries.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarouselCollectionViewCell", for: indexPath) as? CarouselCollectionViewCell else { return CarouselCollectionViewCell()}
        if indexPath.row == targetDayDiaries.count {
            // 最後のentity
            cell.setup(targetDate: targetDate, targetEntity: nil)
        } else {
            cell.setup(targetDate: targetDate, targetEntity: targetDayDiaries[indexPath.row])
        }
        cell.delegate = self
        return cell
    }
}

extension FrontCoverViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // ページ数
        pageCount = indexPath.row
    }
}

extension FrontCoverViewController: DiaryDelegate {
    func postDiary() {
        let nextPageVC = AddDiaryViewController()
        let targetEntity = DiaryEntity()
        targetEntity.date = targetDate
        nextPageVC.targetEntity = targetEntity
        nextPageVC.isNewCreate = true
        navigationController?.pushViewController(nextPageVC, animated: true)
    }
    
    func editDiary() {
        let nextPageVC = AddDiaryViewController()
        nextPageVC.targetEntity = targetDayDiaries[pageCount]
        nextPageVC.isNewCreate = false
        navigationController?.pushViewController(nextPageVC, animated: true)
    }
    
    func deleteDiary() {
        let alert = UIAlertController(title: "本当に消しますか？", message:  "", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "はい", style: .default) { _ in
            RealmUtility().deleteDiary(targetEntity: self.targetDayDiaries[self.pageCount])
            self.targetDayDiaries.remove(at: self.pageCount)
            self.collectionView.reloadData()
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
