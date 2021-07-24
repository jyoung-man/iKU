//
//  MajorViewController.swift
//  iKU
//
//  Created by 박재영 on 2021/02/03.
//

import UIKit
import SwiftSoup
import Alamofire
import RxSwift
import RxCocoa
import RxDataSources
import BonsaiController

class MajorViewController: UIViewController, UISearchBarDelegate {
    let ad = UIApplication.shared.delegate as? AppDelegate
    let ud = UserDefaults.standard
    let cellID = "lCell"
    private var viewModel: LectureListViewModel!
    var datasource: RxTableViewSectionedReloadDataSource<LectureSection>!
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var majorTableView: UITableView!
    @IBOutlet weak var lecSearchBar: UISearchBar!
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var collegeLabel: UILabel!
    @IBOutlet weak var departureLabel: UILabel!
    @IBOutlet weak var inMyGrade: UIButton!
    
    var myDept: String?
    var grade: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ad?.modal_height = self.backgroundView.frame.height
        loadUserInfo()
        lecSearchBar.delegate = self
        self.viewModel = LectureListViewModel(dept: myDept!, classes: "type")

        backgroundView.layer.cornerRadius = backgroundView.frame.height / 25
        lecSearchBar.barTintColor = majorTableView.backgroundColor
        lecSearchBar.searchTextField.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        
        let dSource = RxTableViewSectionedReloadDataSource<LectureSection>(configureCell: { dSource, majorTableView, indexPath, item in
            let cell = majorTableView.dequeueReusableCell(withIdentifier: self.cellID, for: indexPath) as! LectureCell
            cell.titleLabel.text = item.title
            cell.profAndNumberLabel.text = "\(item.prof)/\(item.number)"
            cell.leftLabel.text = item.left
            cell.lecCellView.layer.cornerRadius = cell.lecCellView.frame.height / 3
            
            return cell
        })
        dSource.titleForHeaderInSection = {ds, index in
            return ds.sectionModels[index].lecType}
        self.datasource = dSource
        
        majorTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        viewModel.mutableLectureList()
            .bind(to: majorTableView.rx.items(dataSource: datasource))
            .disposed(by: disposeBag)
        
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
        if myDept != ud.string(forKey: "department") || grade != ud.string(forKey: "grade") {
            loadUserInfo()
            self.viewModel.changeMajor(dept: myDept!)
            //let numberOfSections = self.tableView.numberOfSections
            //let numberOfRows = self.tableView.numberOfRows(inSection: numberOfSections-1)

            let indexPath = IndexPath(row: 0 , section: 0)
            self.majorTableView.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
    
    func loadUserInfo() {
        myDept = ud.string(forKey: "department") ?? "126914"
        grade = ud.string(forKey: "grade") ?? "1"
        
        let mj_info = ud.string(forKey: "mj_info")?.split(separator: " ")
        collegeLabel.text = String((mj_info?[0])!)
        departureLabel.text = String((mj_info?[1])!)
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        //if segue.destination is HalfSizeViewController {
            segue.destination.transitioningDelegate = self
            segue.destination.modalPresentationStyle = .custom
        //}
    }

}

extension MajorViewController: BonsaiControllerDelegate {
    
    func frameOfPresentedView(in containerViewFrame: CGRect) -> CGRect {
        
        return CGRect(origin: CGPoint(x: 0, y: view.frame.size.height - backgroundView.frame.size.height), size: CGSize(width: containerViewFrame.width, height: backgroundView.frame.size.height))
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
    
        return BonsaiController(fromDirection: .bottom, backgroundColor: UIColor(white: 0, alpha: 0.0), presentedViewController: presented, delegate: self)
    }
}



extension MajorViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.returnSize()
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
                let headerView = view as! UITableViewHeaderFooterView
        headerView.contentView.backgroundColor = tableView.backgroundColor
        print(headerView.textLabel)

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //여기서 선택된 과목의 번호를 전달.
        ad?.selected_lecture = viewModel.returnLecture(section: indexPath.section, index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.filterByKeyword(searchText: searchText, flag: false)
    }
    
    
    
}
