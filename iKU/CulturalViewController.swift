//
//  CulturalViewController.swift
//  iKU
//
//  Created by 박재영 on 2021/02/17.
//

import DropDown
import UIKit
import SwiftSoup
import Alamofire

class CulturalViewController: UIViewController, UISearchBarDelegate {
    let ad = UIApplication.shared.delegate as? AppDelegate
    let ud = UserDefaults.standard
    
    @IBOutlet weak var culturalTableView: UITableView!
    @IBOutlet weak var lecSearchBar: UISearchBar!
    @IBOutlet weak var vacantSwitch: UISwitch!
    @IBOutlet weak var isVacant: UILabel!
    @IBOutlet weak var clSegment: UISegmentedControl!
    
    var filteredLec: [Lecture]!
    var lectures: [Lecture]!
    var vacantLec: [Lecture]!
    var searchedLec: [Lecture]!
    var myDept: String?
    var grade: String?
    
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var button: UIButton!
    @IBAction func filter(_ sender: UIButton) {
        menu.show()
    }
    
    let menu: DropDown = {
        let menu = DropDown()
        menu.dataSource = [
            "기교) 외국어, 글쓰기",
            "기교) SW, 취창업, 사회봉사",
            "기교) 유학생을 위한 강의",
            "심교) 사고력증진",
            "심교) 학문소양 및 인성함양",
            "심교) 글로벌 인재양성"
        ]
        return menu
    }()
    
    override var prefersStatusBarHidden: Bool {
            return true
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vacantSwitch.isOn = false
        vacantSwitch.isEnabled = false
        vacantSwitch.onTintColor = .systemTeal
        vacantSwitch.thumbTintColor = .lightGray
        isVacant.text = "전체 강의"
        menu.anchorView = button
        menu.selectRow(0)
        menu.selectionBackgroundColor = .white
        
        menu.selectionAction = { [self] index, title in
            if index == 0 {
                print("00")
                lectures = DBHelper().askLecture(dept: "B0404P", type: "외국어&글쓰기")
            }
            else if index == 1 {
                lectures = DBHelper().askLecture(dept: "B0404P", type: "SW&취창업&인성")
            }
            else if index == 2 {
                lectures = DBHelper().askLecture(dept: "B0404P", type: "외국인글쓰기&한국어&사고와표현")
            }
            else if index == 3 {
                lectures = DBHelper().askLecture(dept: "B04054", type: "사고력증진")
            }
            else if index == 4 {
                lectures = DBHelper().askLecture(dept: "B04054", type: "학문소양및인성함양")
            }
            else if index == 5 {
                lectures = DBHelper().askLecture(dept: "B04054", type: "글로벌인재양성")
            }
            else {
                print("Out of index")
            }
            filteredLec = lectures
            searchedLec = lectures
            segmentChanged(segment)
            lecSearchBar.text = ""
            self.culturalTableView.reloadData()
        }
        grade = ud.string(forKey: "grade") ?? "1"
        culturalTableView.delegate = self
        culturalTableView.dataSource = self
        lectures = DBHelper().askLecture(dept: "B0404P", type: "외국어&글쓰기")
        filteredLec = lectures
        searchedLec = lectures
        lecSearchBar.delegate = self
        print("init_finish")
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
        print("Tap is working")
    }
    override func viewWillAppear(_ animated: Bool) {
        if grade != ud.string(forKey: "grade") {
            grade = ud.string(forKey: "grade") ?? "1"
            removeInfo(lecs: lectures)
            filteredLec = lectures
            searchedLec = lectures
            vacantSwitch.isOn = false
            vacantSwitch.isEnabled = false
            clSegment.selectedSegmentIndex = 0
            isVacant.text = "전체 강의"
            lecSearchBar.text = ""
            self.culturalTableView.reloadData()
        }
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        let switchOn: Bool = vacantSwitch.isOn

        if sender.selectedSegmentIndex == 1 {
            vacantSwitch.isEnabled = false
            seatsForAll(lecs: searchedLec)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if switchOn {
                    self.filterByLeft(lecs: self.searchedLec)
                    self.filteredLec = self.vacantLec
                }
                else {
                    self.filteredLec = self.searchedLec
                }
                self.culturalTableView.reloadData()
                self.vacantSwitch.isEnabled = true
            }
        }
        
        else if sender.selectedSegmentIndex == 2 {
            vacantSwitch.isEnabled = false
            seatsForSenior(lecs: searchedLec)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if switchOn {
                    self.filterByLeft(lecs: self.searchedLec)
                    self.filteredLec = self.vacantLec
                }
                else {
                    self.filteredLec = self.searchedLec
                }
                self.culturalTableView.reloadData()
                self.vacantSwitch.isEnabled = true
            }
        }
        else {
            vacantSwitch.isEnabled = false
            vacantSwitch.isOn = false
            clickSwitch(vacantSwitch)
            self.isVacant.text = "전체 강의"

            for l in searchedLec {
                l.setLeft(refreshed: "")
            }
            filteredLec = searchedLec
            self.culturalTableView.reloadData()
        }
    }
    
    func removeInfo(lecs: [Lecture]) {
        for lec in lecs {
            lec.left = ""
            lec.available = true
        }
    }
    
    
    func seatsForSenior(lecs: [Lecture]) {
        var left: String = " "
        let suguniURL = "https://kupis.konkuk.ac.kr/sugang/acd/cour/aply/CourBasketInwonInq.jsp?ltYy=2021&ltShtm=B01011&promShyr=\(grade ?? "1")&fg=B&sbjtId="
        for lec in lecs {
            guard let url = URL(string: suguniURL+lec.number) else { return }
            AF.request(url).responseString { (response) in
                switch response.result {
                case .success:
                    do {
                        let html = response.value!
                        let doc: Document = try SwiftSoup.parse(html)
                        let values = try doc.select("[align=center]").array()
                        left = try values[0].text()
                        lec.setLeft(refreshed: left)
                    }
                    catch Exception.Error(_, let message) {
                        print(message)
                    } catch {
                        print("error")
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func seatsForAll(lecs: [Lecture]) {
        var left: String = " "
        let suguniURL = "https://kupis.konkuk.ac.kr/sugang/acd/cour/aply/CourInwonInqTime.jsp?ltYy=2021&ltShtm=B01011&sbjtId="
        for lec in lecs {
            guard let url = URL(string: suguniURL+lec.number) else { return }
            AF.request(url).responseString { (response) in
                switch response.result {
                case .success:
                    do {
                        let html = response.value!
                        let doc: Document = try SwiftSoup.parse(html)
                        let srcs = try doc.select("[align=center]").array()
                        let vacant = try srcs[0].text()
                        let max = try srcs[1].text()
                        left = "\(vacant) / \(max)"
                        lec.setLeft(refreshed: left)
                        if vacant < max {
                            lec.setAvailable(flag: true)
                        }
                    }
                    catch Exception.Error(_, let message) {
                        print(message)
                    } catch {
                        print("error")
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    @IBAction func clickSwitch(_ sender: UISwitch) {
        if sender.isOn {
            self.isVacant.text = "빈 강의만"
            filterByLeft(lecs: searchedLec)
            self.filteredLec = vacantLec
        }
        else {
            self.isVacant.text = "전체 강의"
            self.filteredLec = searchedLec
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.culturalTableView.reloadData()
        }
    }
    
    func filterByLeft(lecs: [Lecture]) {
        vacantLec = []
        var temp: [String]
        var m: Int
        var v: Int
        for l in lecs {
            temp = l.left.components(separatedBy: " / ")
            if temp.count > 1 {
                v = Int(temp[0])!
                m = Int(temp[1])!
                if v < m {
                    vacantLec.append(l)
                }
            }
        }
    }
    
    func filterByKeyword(searchText: String) {
        searchedLec = []
        
        if searchText == "" {
            searchedLec = lectures
        }
        else {
            var keyword = searchText.components(separatedBy: " ")
            while keyword.count <= 2 {
                keyword.append(keyword[0])
            }
            
            for lec in lectures {
                if lec.lecInfo.contains(keyword[0]) && lec.lecInfo.contains(keyword[1]) && lec.lecInfo.contains(keyword[2]) {
                    searchedLec.append(lec)
                }
            }
        }
    }
    
    func howManySeats(left: String) -> String {
        let vacant: Int?
        let temp = left.components(separatedBy: " / ")
        if temp.count < 2 {
            return " "
        }
        else {
            let v = temp.map({ (value : String) -> Int in return Int(value)! })
            vacant = v[1] - v[0]
        }
        if vacant! <= 0 {
            return "인원초과"
        }
        else {
            return String(vacant!) + "자리"
        }
    }
    
}
extension CulturalViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredLec.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = culturalTableView.dequeueReusableCell(withIdentifier: "LecCell") as! LectureTableViewCell
        cell.nameLabel.lineBreakMode = .byTruncatingTail
        cell.nameLabel.text = filteredLec[indexPath.row].title
        cell.profLabel.text = filteredLec[indexPath.row].prof
        cell.typeImage.image = UIImage(named: filteredLec[indexPath.row].type)
        cell.numberLabel.text = filteredLec[indexPath.row].number
        cell.leftLabel.text = howManySeats(left: filteredLec[indexPath.row].left)
        if cell.leftLabel.text == "인원초과" {
            cell.leftLabel.textColor = .systemGray3
        }
        else {
            cell.leftLabel.textColor = .green
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //여기서 선택된 과목의 번호를 전달.
        ad?.selected_lec = filteredLec[indexPath.row].number
    }
        
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //filteredLec = []
        filterByKeyword(searchText: searchText)

        if vacantSwitch.isOn {
            filterByLeft(lecs: searchedLec)
        }
        else {
            filteredLec = searchedLec
        }
        self.culturalTableView.reloadData()
    }
}
