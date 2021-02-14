//
//  LectureDetailView.swift
//  iKU
//
//  Created by 박재영 on 2021/02/13.
//

import UIKit

class LectureDetailView: UIViewController {

    @IBOutlet weak var lecDetailTable: UITableView!
    let sections: [String] = ["강의 정보", "시간 및 장소", "담당 교수"]

    override func viewDidLoad() {
        super.viewDidLoad()
        lecDetailTable.delegate = self
        lecDetailTable.dataSource = self

        // Do any additional setup after loading the view.
    }
}

extension LectureDetailView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        else if section == 1 {
            return 3
        }
        else if section == 2 {
            return 4
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = lecDetailTable.dequeueReusableCell(withIdentifier: "lecDetail") as! LectureDetailCell
        cell.cellContents.text = "abab"
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
}
