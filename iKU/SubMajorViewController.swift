//
//  SubMajorViewController.swift
//  iKU
//
//  Created by 박재영 on 2021/02/16.
//

import UIKit
import SwiftSoup
import Alamofire

class SubMajorViewController: UIViewController, UISearchBarDelegate {
    let ad = UIApplication.shared.delegate as? AppDelegate
    let ud = UserDefaults.standard

    @IBOutlet weak var subMajorTableView: UITableView!
    @IBOutlet weak var lecSearchBar: UISearchBar!
    @IBOutlet weak var vacantSwitch: UISwitch!
    @IBOutlet weak var isVacant: UILabel!
    @IBOutlet weak var sjSegment: UISegmentedControl!
    
    var filteredLec: [Lecture]!
    var lectures: [Lecture]!
    var vacantLec: [Lecture]!
    var searchedLec: [Lecture]!
    var dobl: String?
    var sub: String?
    var grade: String?
    var stack: [String]?
    
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
        dobl = ud.string(forKey: "double_major") ?? "126780"
        sub = ud.string(forKey: "sub_major") ?? "B04047"
        let majors = "\(dobl ?? "11")&\(sub ?? "22")"
        grade = ud.string(forKey: "grade") ?? "1"
        subMajorTableView.delegate = self
        subMajorTableView.dataSource = self
        lectures = DBHelper().askLecture(dept: majors, type: "")
        filteredLec = lectures
        searchedLec = lectures
        lecSearchBar.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
        print("Tap is working")
    }
    override func viewWillAppear(_ animated: Bool) {
        if dobl != ud.string(forKey: "double_major") || sub != ud.string(forKey: "sub_major") || grade != ud.string(forKey: "grade") {
            dobl = ud.string(forKey: "double_major") ?? "126780"
            sub = ud.string(forKey: "sub_major") ?? "B04047"
            let majors = "\(dobl ?? "11")&\(sub ?? "22")"
            grade = ud.string(forKey: "grade") ?? "1"
            lectures = DBHelper().askLecture(dept: majors, type: "")
            filteredLec = lectures
            searchedLec = lectures
            vacantSwitch.isOn = false
            vacantSwitch.isEnabled = false
            sjSegment.selectedSegmentIndex = 0
            isVacant.text = "전체 강의"
            lecSearchBar.text = ""
            subMajorTableView.reloadData()
        }
        stack = ud.stringArray(forKey: "stack")

    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        let switchOn: Bool = self.vacantSwitch.isOn

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
                self.subMajorTableView.reloadData()
                self.vacantSwitch.isEnabled = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                self.subMajorTableView.reloadData()
                print("작동중")
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
                self.subMajorTableView.reloadData()
                self.vacantSwitch.isEnabled = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                self.subMajorTableView.reloadData()
                print("작동중")
            }
        }
        
        else {
            vacantSwitch.isEnabled = false
            vacantSwitch.isOn = false
            self.isVacant.text = "전체 강의"
            
            for l in searchedLec {
                l.setLeft(refreshed: "")
            }
            filteredLec = searchedLec
            self.subMajorTableView.reloadData()
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
            self.subMajorTableView.reloadData()
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

extension SubMajorViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredLec.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = subMajorTableView.dequeueReusableCell(withIdentifier: "LecCell") as! LectureTableViewCell
        
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
        let selected_lec = filteredLec[indexPath.row].number
        ad?.selected_lec = selected_lec
        if stack!.count >= 5 {
            stack?.removeFirst()
        }
        stack?.append(selected_lec)
        ud.set(stack, forKey: "stack")
        
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
        self.subMajorTableView.reloadData()
    }
    
}
