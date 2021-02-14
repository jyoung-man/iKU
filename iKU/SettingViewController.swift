//
//  SettingViewController.swift
//  iKU
//
//  Created by 박재영 on 2021/02/11.
//

import UIKit

class SettingViewController: UIViewController {

    
    @IBOutlet weak var setTableview: UITableView!
    var items = ["개발자 정보", "","","학과 정보 재설정"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableview.dataSource = self
        setTableview.delegate = self
        // Do any additional setup after loading the view.
    }

}

extension SettingViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = setTableview.dequeueReusableCell(withIdentifier: "setCell")!
        cell.textLabel?.text = items[indexPath.row]
        if indexPath.row == 3 {
            cell.textLabel?.textColor = .red
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 3 {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
}
