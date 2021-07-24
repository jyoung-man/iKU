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
    var lec_name: String? = "선형대수"
    var lec_code: String? = "0032"
    var lecture: Lecture?
    var f_left: String?
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        viewModel.firstGrade
            .map{ $0 }
            .subscribe(onNext: {
                self.f_left = $0
            })
            .disposed(by: disposeBag)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        lecture = ad?.selected_lecture!
        APIService().findForOneLecture(lec: self.lecture!)
        viewModel.firstGrade.onNext(lecture?.getApplicants(index: 0) ?? "없어요")
        print("\(String(describing: lecture?.title)) \(String(describing: lecture?.number)) 1학년 \(viewModel.firstGrade)명 신청")
        nameLabel.text = lecture?.title
        print(lecture?.applicants ?? ["몰라여"])
    }
}
