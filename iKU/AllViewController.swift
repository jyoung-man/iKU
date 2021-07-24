//
//  AllViewController.swift
//  iKU
//
//  Created by 박재영 on 2021/02/25.
//
import DropDown
import UIKit
import SwiftSoup
import Alamofire

class AllViewController: UIViewController, UISearchBarDelegate {
    let ad = UIApplication.shared.delegate as? AppDelegate
    let ud = UserDefaults.standard
    @IBOutlet weak var allTableView: UITableView!
    @IBOutlet weak var lecSearchBar: UISearchBar!
    @IBOutlet weak var vacantSwitch: UISwitch!
    @IBOutlet weak var isVacant: UILabel!
    @IBOutlet weak var aSegment: UISegmentedControl!
    
    var depts = DBHelper().askDept()
    var mymajor = [Department(d_name: "교직", d_code: "B04047")]
    var filteredLec: [Lecture]!
    var lectures: [Lecture]!
    var vacantLec: [Lecture]!
    var searchedLec: [Lecture]!
    var myDept: String?
    var grade: String?
    var dropDownIndex: Int = 3
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var button: UIButton!
    @IBAction func filter(_ sender: UIButton) {
        menu.show()
    }
    
    let menu: DropDown = {
        var depts = DBHelper().askDept()
        var mymajor = [Department(d_name: "교직", d_code: "B04047")]
        mymajor += depts
        let menu = DropDown()
        for m in mymajor {
            menu.dataSource.append(m.d_name)
        }
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
        mymajor += depts
        menu.anchorView = button
        menu.selectRow(dropDownIndex)
        menu.selectionBackgroundColor = .white
        
        menu.selectionAction = { [self] index, title in
            dropDownIndex = index
            lectures = DBHelper().askLecture(dept: mymajor[index].d_code, type: "")
            filteredLec = lectures
            searchedLec = lectures
            segmentChanged(segment)
            lecSearchBar.text = ""
        }
        grade = ud.string(forKey: "grade") ?? "1"
        allTableView.delegate = self
        allTableView.dataSource = self
        lectures = DBHelper().askLecture(dept: "126914", type: "")
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
        if grade != ud.string(forKey: "grade") {
            grade = ud.string(forKey: "grade") ?? "1"
            removeInfo(lecs: lectures)
            filteredLec = lectures
            searchedLec = lectures
            vacantSwitch.isOn = false
            vacantSwitch.isEnabled = false
            aSegment.selectedSegmentIndex = 0
            isVacant.text = "전체 강의"
            lecSearchBar.text = ""
            allTableView.reloadData()
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
                self.allTableView.reloadData()
                self.vacantSwitch.isEnabled = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                self.allTableView.reloadData()
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
                self.allTableView.reloadData()
                self.vacantSwitch.isEnabled = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                self.allTableView.reloadData()
                print("작동중")
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
            self.allTableView.reloadData()
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
            self.allTableView.reloadData()
        }
    }
    
    func removeInfo(lecs: [Lecture]) {
        for lec in lecs {
            lec.left = ""
            lec.isAvailable = true
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
extension AllViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredLec.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = allTableView.dequeueReusableCell(withIdentifier: "LecCell") as! LectureTableViewCell
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
        self.allTableView.reloadData()
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
