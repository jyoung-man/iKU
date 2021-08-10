//
//  LectureDetailView.swift
//  iKU
//
//  Created by 박재영 on 2021/02/13.
//

import UIKit

class LectureDetailView: UIViewController {

    @IBOutlet weak var lecDetailTable: UITableView!
    @IBOutlet weak var table: UITableView!
    let ad = UIApplication.shared.delegate as? AppDelegate
    
    let sections: [String] = ["강의 정보", "시간 및 장소", "담당 교수", "비고"]
    var prof_contact = [String]()
    let prof_private: [String] = ["담당 교수님이 정보를 공개하지 않았습니다.", "건국대 포탈에서 검색해 보세요", " "]
    var lec_code: String?
    var lecture = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        lecDetailTable.delegate = self
        lecDetailTable.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {

        //lec_code = ad?.stack?.peak()
        lecture = DBHelper().askLecInfo(l_number: lec_code!)
        prof_contact = DBHelper().askProf(l_number: lec_code!)
        lecDetailTable.rowHeight = UITableView.automaticDimension
        lecDetailTable.separatorStyle = .none
    }
}

extension LectureDetailView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 4
        }
        else if section == 1 {
            return 3
        }
        else if section == 2 {
            return 3
        }
        else if section == 3 {
            return 1
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = lecDetailTable.dequeueReusableCell(withIdentifier: "lecDetail") as! LectureDetailCell
        
        if indexPath.section == 0 {
            cell.sectionImage.image = UIImage(named: "0")
            cell.cellContents.text = lecture[indexPath.row] //0396, 1732, 1228, 0361, 1234
        }
        else if indexPath.section == 1 {
            cell.sectionImage.image = UIImage(named: "1")
            cell.cellContents.text = lecture[indexPath.row + 4]
        }
        else if indexPath.section == 2 {
            if prof_contact.isEmpty {
                cell.cellContents.text = prof_private[indexPath.row]
            }
            else {
                cell.sectionImage.image = UIImage(named: "2")
                cell.cellContents.text = prof_contact[indexPath.row]
            }
        }
        else if indexPath.section == 3 {
            cell.cellContents.lineBreakMode = .byWordWrapping
            cell.cellContents.numberOfLines = 0
            cell.sectionImage.image = UIImage(named: "3")

            if lecture[indexPath.row + 7].isEmpty {
                cell.cellContents.text = " "
            }
            else {
                cell.cellContents.text = lecture[indexPath.row + 7]
            }
        }
        else {
            cell.cellContents.text = ""
        }
        
        return cell
    }
    

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}
