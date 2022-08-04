//
//  PresentFreePrintCountPerMonthViewController.swift
//  albumdiary
//
//  Created by nonakashiho on 2022/07/02.
//

import UIKit

final class PresentFreePrintCountPerMonthViewController: UIViewController {
    
    
    @IBOutlet private weak var freePrintCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let freePrintCount = UserDefaultUtility().freePrintCountPerMonth()
        freePrintCountLabel.text =
        "印刷可能枚数\n \(freePrintCount)枚 → 10枚"
        
        // 10枚にリセット
        UserDefaultUtility().setFreePrintCountPerMonth()
    }
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true)
    }
    


}
