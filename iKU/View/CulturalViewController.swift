//
//  CulturalViewController.swift
//  iKU
//
//  Created by 박재영 on 2021/02/17.
//

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

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var culturalTableView: UITableView!
    @IBOutlet weak var lecSearchBar: UISearchBar!
    
    var lectures: [Lecture]!
    var vacantLec: [Lecture]!
    var searchedLec: [Lecture]!
    var myDept: String?
    var grade: String?
    var stack: [String]?
    var flag: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        grade = ud.string(forKey: "grade") ?? "1"
        lecSearchBar.delegate = self
        scrollView.layer.cornerRadius = 12
        self.viewModel = LectureListViewModel(dept: "B0404P", classes: "section")
        backgroundView.layer.cornerRadius = backgroundView.frame.height / 25
        lecSearchBar.barTintColor = culturalTableView.backgroundColor
        lecSearchBar.searchTextField.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        let dSource = RxTableViewSectionedReloadDataSource<LectureSection>(
            configureCell: { dataSource, culturalTableView, indexPath, item in
                let cell = culturalTableView.dequeueReusableCell(withIdentifier: self.cellID, for: indexPath) as! LectureCell
                item.mvvm
                    .map{ $0 }
                    .subscribe(onNext: {
                        cell.leftLabel.text = $0
                    })
                cell.titleLabel.text = item.title
                cell.profAndNumberLabel.text = "\(item.prof)/\(item.number)"
                cell.lecCellView.layer.borderWidth = 1
                cell.lecCellView.layer.borderColor = CGColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1)
                cell.lecCellView.layer.cornerRadius = cell.lecCellView.frame.height / 3
                cell.lecCellView.layer.masksToBounds = true
                cell.shadowLayer.layer.cornerRadius = cell.lecCellView.frame.height / 3
                cell.shadowLayer.layer.masksToBounds = false
                cell.shadowLayer.layer.shadowOffset = CGSize(width: 0, height: 10)
                cell.shadowLayer.layer.shadowColor = UIColor.black.cgColor
                cell.shadowLayer.layer.shadowOpacity = 0.03
                cell.shadowLayer.layer.shadowRadius = cell.lecCellView.frame.height / 3
                cell.shadowLayer.layer.shadowPath = UIBezierPath(roundedRect: cell.shadowLayer.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 2, height: 1)).cgPath
                cell.shadowLayer.layer.shouldRasterize = true
                cell.shadowLayer.layer.rasterizationScale = UIScreen.main.scale
                return cell
            })
        dSource.titleForHeaderInSection = { ds, index in
            return ds.sectionModels[index].lecType
        }
        self.datasource = dSource
        
        culturalTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        viewModel.mutableLectureList()
            .bind(to: culturalTableView.rx.items(dataSource: datasource))
            .disposed(by: disposeBag)

        print("init_finish")
        
        //viewModel.changeCulturalSection(index: 0)
        
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
        stack = ud.stringArray(forKey: "stack")
    }
    
    func removeInfo(lecs: [Lecture]) {
        for lec in lecs {
            lec.left = ""
            lec.isAvailable = true
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
    //왼쪽 목록 만드는 법: 각 구성요소를 버튼으로 만들어 배치한다. > 색이 다른 버튼도 하나의 뷰로 만들어 배치한다 > 버튼을 파라미터로 받아 색이 다른 버튼을 버튼의 시작 위치에 배치하고 내부 텍스트도 변경하는 함수를 작성한다 > 작성된 함수를 뷰 컨트롤러에 배치된 버튼들의 IBAction으로 설정한다.
}
extension CulturalViewController: UITableViewDelegate {
    
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
        print(indexPath)
        let selected_lec = viewModel.returnNumCode(section: indexPath.section, index: indexPath.row)
        ad?.selected_lec = selected_lec
        if stack?.count ?? 0 >= 5 {
            stack?.removeFirst()
        }
        stack?.append(selected_lec)
        ud.set(stack, forKey: "stack")
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.filterByKeyword(searchText: searchText, flag: self.flag)
    }
}
