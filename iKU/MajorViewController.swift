//
//  MajorViewController.swift
//  iKU
//
//  Created by 박재영 on 2021/02/03.
//

import UIKit
import SwiftSoup
import Alamofire

class MajorViewController: UIViewController, UISearchBarDelegate, XMLParserDelegate {
    
    let ad = UIApplication.shared.delegate as? AppDelegate

    @IBOutlet weak var majorTableView: UITableView!
    @IBOutlet weak var lecSearchBar: UISearchBar!
    
    var filteredLec: [Lecture]!
    var lectures: [Lecture]!
    var myDept: String?
    var grade: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myDept = ad?.department!
        grade = ad?.grade!
        majorTableView.delegate = self
        majorTableView.dataSource = self
        lectures = DBHelper().askMajor(dept: myDept!, type: "")
        print(myDept!)
        filteredLec = lectures
        lecSearchBar.delegate = self
        print("init_finish")

    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        let seconds = 1.0
        
        if sender.selectedSegmentIndex == 0 {
            //filteredLec = []
            for l in filteredLec {
                
                l.setAvailable(refreshed: "")
                //filteredLec.append(l)
            }
            self.majorTableView.reloadData()
        }
        
        else if sender.selectedSegmentIndex == 1 {
            //filteredLec = []
            for l in filteredLec {
                seatsForAll(lec: l)
                //filteredLec.append(l)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                self.majorTableView.reloadData()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                self.majorTableView.reloadData()
                print("작동중")
            }
        }
        
        else if sender.selectedSegmentIndex == 2 {
            //filteredLec = []
            for l in filteredLec {
                seatsForSenior(lec: l)
                //filteredLec.append(l)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                self.majorTableView.reloadData()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                self.majorTableView.reloadData()
            }
        }
        //self.majorTableView.scrollToRow(at: start, at: .top, animated: true)
    }
    
    func seatsForSenior(lec: Lecture) {
        var left: String = " "
        let suguniURL = "https://kupis.konkuk.ac.kr/sugang/acd/cour/aply/CourBasketInwonInq.jsp?ltYy=2021&ltShtm=B01011&promShyr=\(grade ?? "1")&fg=B&sbjtId=\(lec.number)"
        guard let url = URL(string: suguniURL) else { return }
        AF.request(url).responseString { (response) in
            do {
                let html = response.value!
                let doc: Document = try SwiftSoup.parse(html)
                let values = try doc.select("[align=center]").array()
                left = try values[0].text()
                lec.setAvailable(refreshed: left)
            }
            catch Exception.Error(_, let message) {
                print(message)
            } catch {
                print("error")
            }
        }
    }
    
    func seatsForAll(lec: Lecture) {
        var left: String = " "
        let suguniURL = "https://kupis.konkuk.ac.kr/sugang/acd/cour/aply/CourInwonInqTime.jsp?ltYy=2021&ltShtm=B01011&sbjtId=\(lec.number)"
        guard let url = URL(string: suguniURL) else { return }
        AF.request(url).responseString { (response) in
                do {
                    let html = response.value!
                    let doc: Document = try SwiftSoup.parse(html)
                    let srcs = try doc.select("[align=center]").array()
                    let vacant = try srcs[0].text()
                    let max = try srcs[1].text()
                    left = "\(vacant) / \(max)"
                    lec.setAvailable(refreshed: left)
                }
                catch Exception.Error(_, let message) {
                    print(message)
                } catch {
                    print("error")
                }
            }
        
    }
}

extension MajorViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredLec.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = majorTableView.dequeueReusableCell(withIdentifier: "LecCell") as! LectureTableViewCell
        
        cell.nameLabel.text = filteredLec[indexPath.row].title
        cell.profLabel.text = filteredLec[indexPath.row].prof
        cell.typeImage.image = UIImage(named: filteredLec[indexPath.row].type)
        cell.numberLabel.text = filteredLec[indexPath.row].number
        cell.leftLabel.text = filteredLec[indexPath.row].available
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(filteredLec[indexPath.row].number)
        //여기서 선택된 과목의 번호를 전달.
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        
        filteredLec = []
        
        if searchText == "" {
            filteredLec = lectures
        }
        else {
            for lec in lectures {
                if lec.lecInfo.contains(searchText) {
                    filteredLec.append(lec)
                }
            }


        }
        self.majorTableView.reloadData()

    }
    
}
