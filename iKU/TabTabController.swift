//
//  TabTabController.swift
//  iKU
//
//  Created by 박재영 on 2021/02/03.
//

import UIKit

class TabTabController: UITabBarController {
    let ud = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        let alert = UIAlertController(title: "알림", message: "수강신청 전 과목 정보를 꼭 확인하세요. \n현재 설정된 학년은 \(ud.string(forKey: "grade") ?? "1")학년입니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
//        let alert = UIAlertController(title: "요청 취소", message: "요청을 취소하면 촬영하신 이미지가 전부 삭제됩니다. 계속 진행하시겠습니까?", preferredStyle: .alert)
//            let action = UIAlertAction(title: "계속 진행", style: .destructive) { (action) in
//                self.navigationController?.setNavigationBarHidden(false, animated: true)
//                self.navigationController?.popViewController(animated: true)
//            }
//            let cancel = UIAlertAction(title: "돌아가기", style: .cancel, handler: nil)
//            alert.addAction(action)
//            alert.addAction(cancel)
//            present(alert, animated: true, completion: nil)
    }
}
