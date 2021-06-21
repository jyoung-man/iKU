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
import RxSwift
import RxCocoa
import RxDataSources

class CulturalViewController: UIViewController, UISearchBarDelegate {
    let ad = UIApplication.shared.delegate as? AppDelegate
    let ud = UserDefaults.standard
    let cellID = "lCell"
    private var viewModel: LectureListViewModel!
    var datasource: RxTableViewSectionedReloadDataSource<LectureSection>!
    var disposeBag = DisposeBag()

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var culturalTableView: UITableView!
    @IBOutlet weak var lecSearchBar: UISearchBar!
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel = LectureListViewModel()
        backgroundView.layer.cornerRadius = backgroundView.frame.height / 25
        menu.anchorView = button
        menu.selectRow(0)
        menu.selectionBackgroundColor = .white
        lecSearchBar.barTintColor = culturalTableView.backgroundColor
        lecSearchBar.searchTextField.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        let dataSource = RxTableViewSectionedReloadDataSource<LectureSection>(
            configureCell: { dataSource, culturalTableView, indexPath, item in
                let cell = culturalTableView.dequeueReusableCell(withIdentifier: self.cellID, for: indexPath) as! LectureCell
                cell.titleLabel.text = item.title
                cell.profAndNumberLabel.text = "\(item.prof)/\(item.number)"
                cell.leftLabel.text = item.left
                cell.lecCellView.layer.cornerRadius = cell.lecCellView.frame.height / 3
                
                return cell
            })
        dataSource.titleForHeaderInSection = { ds, index in
            return ds.sectionModels[index].lecType
        }
        self.datasource = dataSource
        
        culturalTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        viewModel.mutableLectureList()
            .bind(to: culturalTableView.rx.items(dataSource: datasource))
            .disposed(by: disposeBag)

        menu.selectionAction = { [self] index, title in
            viewModel.changeCulturalSection(index: index)
        }
        grade = ud.string(forKey: "grade") ?? "1"
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
            lecSearchBar.text = ""
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

}
extension CulturalViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.returnSize()
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
                let headerView = view as! UITableViewHeaderFooterView
        headerView.contentView.backgroundColor = tableView.backgroundColor
                headerView.contentView.layer.cornerRadius = 0
                headerView.contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //여기서 선택된 과목의 번호를 전달.
        ad?.selected_lec = viewModel.returnNumCode(index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 55
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.filterByKeyword(searchText: searchText, flag: true)
    }
}
