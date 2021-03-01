//
//  SettingViewController.swift
//  iKU
//
//  Created by 박재영 on 2021/02/11.
//

import UIKit

class SettingViewController: UIViewController {

    
    @IBOutlet weak var setTableview: UITableView!
    var items = ["jyp13.jyp@gmail.com", " ","학과 정보 재설정"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableview.dataSource = self
        setTableview.delegate = self
    }

}

extension SettingViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = setTableview.dequeueReusableCell(withIdentifier: "setCell")!
        cell.textLabel?.text = items[indexPath.row]
        if indexPath.row == 2 {
            cell.textLabel?.textColor = .red
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let email = "jyp13.jyp@gmail.com"
            /*
            if let url = URL(string: "mailto:\(email)") {
              if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
              } else {
                UIApplication.shared.openURL(url)
              }
            }*/
        }
        
        else if indexPath.row == 2 {
            let alert = UIAlertController(title: "주의", message: "학과 정보를 다시 설정하시겠습니까?", preferredStyle: .alert)
                let action = UIAlertAction(title: "다시 설정", style: .destructive) { (action) in
                    self.navigationController?.setNavigationBarHidden(false, animated: true)
                    self.navigationController?.popViewController(animated: true)
                }
                let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
                alert.addAction(action)
                alert.addAction(cancel)
                present(alert, animated: true, completion: nil)

            
            //self.navigationController?.setNavigationBarHidden(false, animated: true)
            //self.navigationController?.popViewController(animated: true)
        }
    }
    
    
}
