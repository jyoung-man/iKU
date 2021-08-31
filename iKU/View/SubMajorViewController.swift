//
//  SubMajorViewController.swift
//  iKU
//
//  Created by 박재영 on 2021/02/16.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import BonsaiController

class SubMajorViewController: UIViewController, UISearchBarDelegate {
    let ad = UIApplication.shared.delegate as? AppDelegate
    let ud = UserDefaults.standard
    let cellID = "lCell"
    private var viewModel: LectureListViewModel!
    var datasource: RxTableViewSectionedReloadDataSource<LectureSection>!
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var submajorTableView: UITableView!
    @IBOutlet weak var lecSearchBar: UISearchBar!
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var secondMajorLabel: UILabel!
    @IBOutlet weak var thirdMajorLabel: UILabel!
    
    @IBOutlet weak var allGrade: UIButton!
    @IBOutlet weak var myGrade: UIButton!
    
    @IBOutlet weak var vacantButton: UIButton!
    
    var secondDept: String?
    var thirdDept: String?
    var mymajors: String = ""
    var gradeValue: String?
    var flag: Int = 1
    var buttonActivated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserInfo()
        self.viewModel = LectureListViewModel(dept: mymajors, classes: "type")

        backgroundView.layer.cornerRadius = backgroundView.frame.height / 15
        lecSearchBar.delegate = self
        lecSearchBar.barTintColor = submajorTableView.backgroundColor
        lecSearchBar.searchTextField.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        
        let dSource = RxTableViewSectionedReloadDataSource<LectureSection>(configureCell: { dSource, submajorTableView, indexPath, item in
            let cell = submajorTableView.dequeueReusableCell(withIdentifier: self.cellID, for: indexPath) as! LectureCell
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
        
        submajorTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        viewModel.mutableLectureList()
            .bind(to: submajorTableView.rx.items(dataSource: datasource))
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
        if secondDept != ud.string(forKey: "double_major") || thirdDept != ud.string(forKey: "sub_major") || gradeValue != ud.string(forKey: "grade") {
            loadUserInfo()
            self.viewModel.changeMajor(dept: mymajors)
            let indexPath = IndexPath(row: 0 , section: 0)
            self.submajorTableView.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
    
    func changeTarget(flag: Int) {
        self.lecSearchBar.searchTextField.text = ""
        viewModel.filterByKeyword(searchText: "", flag: flag)
        viewModel.countSeats(flag: flag, myGrade: gradeValue!)
        self.flag = flag
        self.buttonActivated = false
        self.vacantButton.isSelected = false
    }
    
    func loadUserInfo() {
        secondDept = ud.string(forKey: "double_major") ?? "999999"
        thirdDept = ud.string(forKey: "sub_major") ?? "999999"
        mymajors = secondDept! + "&" + thirdDept!
        gradeValue = ud.string(forKey: "grade") ?? "1"
        
        let dm_info = ud.string(forKey: "dm_info")?.split(separator: " ")
        let sm_info = ud.string(forKey: "sm_info")?.split(separator: " ")
        
        if (dm_info![0] == "없음" && sm_info![0] == "없음") {//둘 다 없는 경우
            thirdMajorLabel.text = "다/부전공이 없습니다."
            secondMajorLabel.text = " "
        }
        else { //둘 중 하나라도 있는 경우
            if (sm_info![0] == "없음") {   //둘 중 하나는 있는데 그게 2번인 경우
                thirdMajorLabel.text = String((dm_info?.last) ?? "")
                secondMajorLabel.text = " "
            }
            else {  //어쨌든 3번에는 있는 경우
                secondMajorLabel.text = String((dm_info?.last) ?? "")
                thirdMajorLabel.text = String((sm_info?.last) ?? "")
            }
        }
        vacantButton.setBackgroundImage(UIImage(named: "vacantOnly_selected"), for: .selected)
        vacantButton.setBackgroundImage(UIImage(named: "vacantOnly"), for: .normal)
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

extension SubMajorViewController: BonsaiControllerDelegate {
    
    func frameOfPresentedView(in containerViewFrame: CGRect) -> CGRect {
        
        return CGRect(origin: CGPoint(x: 0, y: allGrade.frame.origin.y), size: CGSize(width: containerViewFrame.width, height: view.frame.size.height - allGrade.frame.origin.y + 49))
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
    
        return BonsaiController(fromDirection: .bottom, backgroundColor: UIColor(white: 0, alpha: 0.0), presentedViewController: presented, delegate: self)
    }
}



extension SubMajorViewController: UITableViewDelegate {
    
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
