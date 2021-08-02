//
//  LectureInfoViewController.swift
//  iKU
//
//  Created by 박재영 on 2021/06/26.
//

import UIKit
import RxSwift
import RxCocoa

class LectureInfoViewController: UIViewController {
    let ad = UIApplication.shared.delegate as? AppDelegate
    let viewModel = LectureInfoViewModel()
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var titleView: UIView!
    var lec_name: String? = "선형대수"
    var lec_code: String? = "0032"
    var lecture: Lecture?
    var f_left: String?
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleView.layer.borderWidth = 1
        titleView.layer.borderColor =  CGColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1)
        titleView.layer.cornerRadius = 30
    }
    override func viewWillAppear(_ animated: Bool) {
        lecture = ad?.selected_lecture!
        nameLabel.text = lecture?.title
    }
}
