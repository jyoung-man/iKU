//
//  MajorViewController.swift
//  iKU
//
//  Created by 박재영 on 2021/02/03.
//

import UIKit
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
    @IBOutlet weak var allGrade: UIButton!
    @IBOutlet weak var myGrade: UIButton!
    
    @IBOutlet weak var vacantButton: UIButton!
    
    var myDept: String?
    var gradeValue: String?
    var flag: Int = 1
    var buttonActivated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserInfo()
        self.viewModel = LectureListViewModel(dept: myDept!, classes: "type")

        backgroundView.layer.cornerRadius = backgroundView.frame.height / 15
        lecSearchBar.delegate = self
        lecSearchBar.barTintColor = majorTableView.backgroundColor
        lecSearchBar.searchTextField.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        let dSource = RxTableViewSectionedReloadDataSource<LectureSection>(configureCell: { dSource, majorTableView, indexPath, item in
            let cell = majorTableView.dequeueReusableCell(withIdentifier: self.cellID, for: indexPath) as! LectureCell
            item.mvvm
                .map{ $0 }
                .subscribe(onNext: {
                    cell.leftLabel.text = $0
                    self.viewModel.makeItRed(cell: cell, left: $0)
                }).disposed(by: cell.disposeBag) //셀이 화면에서 보이지 않을 때는 bind를 풀어줘야 함
            cell.titleLabel.text = item.title
            cell.profAndNumberLabel.text = "\(item.prof)/\(item.number)"
            cell.leftLabel.text = item.left
            self.viewModel.setCellLooks(cell: cell)
            self.viewModel.makeItRed(cell: cell, left: cell.leftLabel.text ?? "0/2")
            return cell
        })
        dSource.titleForHeaderInSection = {ds, index in
            return ds.sectionModels[index].lecType}
        self.datasource = dSource
        
//        majorTableView.rx.willDisplayCell.subscribe(onNext: { ccell, indexPath in
//            let lecCell = self.majorTableView.dequeueReusableCell(withIdentifier: self.cellID, for: indexPath) as! LectureCell
//            let left = lecCell.leftLabel.text
//            if !self.isAvailable(left: left ?? "0/2") {
//                lecCell.titleLabel.textColor = .systemRed
//            }
//            else {
//                lecCell.titleLabel.textColor = .darkGray
//            }
//        })
        
        majorTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        viewModel.mutableLectureList()
            .bind(to: majorTableView.rx.items(dataSource: datasource))
            .disposed(by: disposeBag)
        
        print("init_finish")

        viewModel.countSeats(flag: 0, myGrade: gradeValue!)

        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    @IBAction func vacantOnly(_ sender: Any) {
        self.buttonActivated = !buttonActivated
        viewModel.filterByLeft(isActivated: self.buttonActivated, flag: self.flag)
        if self.buttonActivated {
            self.vacantButton.isSelected = true
        }
        else {
            self.vacantButton.isSelected = false
        }
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
        print("Tap is working")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if myDept != ud.string(forKey: "department") || gradeValue != ud.string(forKey: "grade") {
            loadUserInfo()
            self.viewModel.changeMajor(dept: myDept!)
            let indexPath = IndexPath(row: 0, section: 0)
            self.majorTableView.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
    
    func loadUserInfo() {
        myDept = ud.string(forKey: "department") ?? "126914"
        gradeValue = ud.string(forKey: "grade") ?? "1"
        
        let mj_info = ud.string(forKey: "mj_info")?.split(separator: " ")
        collegeLabel.text = String((mj_info?[0])!)
        departureLabel.text = String((mj_info?.last)!)
        vacantButton.setBackgroundImage(UIImage(named: "vacantOnly_selected"), for: .selected)
        vacantButton.setBackgroundImage(UIImage(named: "vacantOnly"), for: .normal)
    }
    
    func changeTarget(flag: Int) {
        self.lecSearchBar.searchTextField.text = ""
        viewModel.filterByKeyword(searchText: "", flag: flag)
        viewModel.countSeats(flag: flag, myGrade: gradeValue!)
        self.flag = flag
        self.buttonActivated = false
        self.vacantButton.isSelected = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination.transitioningDelegate = self
        segue.destination.modalPresentationStyle = .custom
    }
    @IBAction func inAllGrade(_ sender: Any) {
        changeTarget(flag: 0)
    }
    @IBAction func inMyGrade(_ sender: Any) {
        changeTarget(flag: 1)
    }
    
}

extension MajorViewController: BonsaiControllerDelegate {
    
    func frameOfPresentedView(in containerViewFrame: CGRect) -> CGRect {
        
        return CGRect(origin: CGPoint(x: 0, y: allGrade.frame.origin.y), size: CGSize(width: containerViewFrame.width, height: view.frame.size.height - allGrade.frame.origin.y + 49))
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
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //여기서 선택된 과목의 번호를 전달.
        viewModel.returnNumCode(section: indexPath.section, index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? LectureCell else { return }
        cell.disposeBag = DisposeBag()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.filterByKeyword(searchText: searchText, flag: self.flag)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
}
