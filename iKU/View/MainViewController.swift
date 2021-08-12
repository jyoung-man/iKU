//
//  MainViewController.swift
//  iKU
//
//  Created by 박재영 on 2021/08/07.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var myMajorLabel: UILabel!
    @IBOutlet weak var myMajorButton: UIButton!
    @IBOutlet weak var first_dabuButton: UIButton!
    @IBOutlet weak var first_dabuLabel: UILabel!
    @IBOutlet weak var second_dabuLabel: UILabel!
    @IBOutlet weak var second_dabuButton: UIButton!
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var majorBarView: UIView!
    @IBOutlet weak var myGradeLabel: UILabel!
    @IBOutlet weak var recentTableView: UITableView!
    @IBOutlet weak var kuImg: UIButton!
    
    let ad = UIApplication.shared.delegate as? AppDelegate
    let ud = UserDefaults.standard
    var recent = [String]()
    var lectures = [[String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //recentTableView.dataSource = self
        //recentTableView.delegate = self
        searchBarView.layer.cornerRadius = 20
        majorBarView.layer.cornerRadius = 20
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let mj_info = ud.string(forKey: "mj_info")?.split(separator: " ")
        let dm_info = ud.string(forKey: "dm_info")?.split(separator: " ")
        let sm_info = ud.string(forKey: "sm_info")?.split(separator: " ")

        
        myMajorLabel.text = String((mj_info?[1])!)
        first_dabuLabel.text = String((dm_info?[1])!)
        second_dabuLabel.text = String((sm_info?[1])!)
        let grade_info = ud.string(forKey: "grade")
        myGradeLabel.text = grade_info! + "학년"
        kuImg.setBackgroundImage(UIImage(named: self.myGradeLabel.text ?? "3학년"), for: .normal)
        recent = ud.stringArray(forKey: "stack") ?? []
        for r in recent {
            let lecture = DBHelper().askLecInfo(l_number: r)
            lectures.append(lecture)
        }
    }
    
    func setButtonAttribute(button: UIButton) {
        button.layer.borderWidth = 1.0
        button.layer.borderColor = CGColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1)
    }
    @IBAction func gotoRoot(_ sender: Any) {
        _ = navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func goBack1(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func goBack2(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func goBack3(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = recentTableView.dequeueReusableCell(withIdentifier: "LecCell") as! LectureTableViewCell

        cell.nameLabel.text = lectures[indexPath.row][0]
        cell.profLabel.text = lectures[indexPath.row][0]
        cell.numberLabel.text = lectures[indexPath.row][0]
        //cell.leftLabel.text = howManySeats(left: filteredLec[indexPath.row].left)
        if cell.leftLabel.text == "인원초과" {
            cell.leftLabel.textColor = .systemGray3
        }
        else {
            cell.leftLabel.textColor = .green
        }
        return cell
    }

}
