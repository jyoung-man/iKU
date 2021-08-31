//
//  CulturalViewController.swift
//  iKU
//
//  Created by 박재영 on 2021/02/17.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import BonsaiController

class CulturalViewController: UIViewController, UISearchBarDelegate {
    let ad = UIApplication.shared.delegate as? AppDelegate
    let ud = UserDefaults.standard
    let cellID = "lCell"
    private var viewModel: LectureListViewModel!
    var datasource: RxTableViewSectionedReloadDataSource<LectureSection>!
    var disposeBag = DisposeBag()

    @IBOutlet weak var allGrade: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var culturalTableView: UITableView!
    @IBOutlet weak var lecSearchBar: UISearchBar!
    @IBOutlet weak var sectionLabel: UILabel!
    @IBOutlet weak var sectionDetail: UILabel!
    
    @IBOutlet weak var vacantButton: UIButton!
    
    var lectures: [Lecture]!
    var vacantLec: [Lecture]!
    var searchedLec: [Lecture]!
    var myDept: String?
    var grade: String?
    var flag: Int = 0
    var buttonActivated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        grade = ud.string(forKey: "grade") ?? "1"
        lecSearchBar.delegate = self
        scrollView.layer.cornerRadius = 12
        self.viewModel = LectureListViewModel(dept: "B0404P", classes: "section")
        backgroundView.layer.cornerRadius = backgroundView.frame.height / 15
        lecSearchBar.barTintColor = culturalTableView.backgroundColor
        lecSearchBar.searchTextField.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        vacantButton.setBackgroundImage(UIImage(named: "vacantOnly_selected"), for: .selected)
        vacantButton.setBackgroundImage(UIImage(named: "vacantOnly"), for: .normal)
        let dSource = RxTableViewSectionedReloadDataSource<LectureSection>(
            configureCell: { dataSource, culturalTableView, indexPath, item in
                let cell = culturalTableView.dequeueReusableCell(withIdentifier: self.cellID, for: indexPath) as! LectureCell
                item.mvvm
                    .map{ $0 }
                    .subscribe(onNext: {
                        cell.leftLabel.text = $0
                        self.viewModel.makeItRed(cell: cell, left: $0)
                    }).disposed(by: cell.disposeBag) 
                cell.leftLabel.text = item.left
                cell.titleLabel.text = item.title
                cell.profAndNumberLabel.text = "\(item.prof)/\(item.number)"
                self.viewModel.setCellLooks(cell: cell)
                self.viewModel.makeItRed(cell: cell, left: cell.leftLabel.text ?? "0/2")
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
        
        viewModel.changeCulturalSection(index: 3, grade: grade!, flag: flag)
        setLable()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    func changeSectionInHere(index: Int, grade: String, flag: Int) {
        viewModel.changeCulturalSection(index: index, grade: grade, flag: flag)
        let indexPath = IndexPath(row: 0 , section: 0)
        self.culturalTableView.scrollToRow(at: indexPath, at: .top, animated: false)
        lecSearchBar.text = ""
        setLable()
        self.buttonActivated = false
        self.vacantButton.isSelected = false
    }
    
    func setLable() {
        let info = viewModel.getCultureSectionInfo()
        sectionLabel.text = info[0]
        sectionDetail.text = info[1]
    }
    
    func changeTarget(flag: Int) {
        self.lecSearchBar.searchTextField.text = ""
        viewModel.filterByKeyword(searchText: "", flag: flag)
        viewModel.countSeats(flag: flag, myGrade: grade!)
        self.flag = flag
        self.buttonActivated = false
        self.vacantButton.isSelected = false
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
    @IBAction func startup(_ sender: Any) {
        changeSectionInHere(index: 0, grade: grade!, flag: flag)
    }
    
    @IBAction func volunteer(_ sender: Any) {
        changeSectionInHere(index: 1, grade: grade!, flag: flag)
    }
    
    @IBAction func language(_ sender: Any) {
        changeSectionInHere(index: 2, grade: grade!, flag: flag)
    }
    
    @IBAction func writing(_ sender: Any) {
        changeSectionInHere(index: 3, grade: grade!, flag: flag)
    }
    @IBAction func omg(_ sender: Any) {
        changeSectionInHere(index: 8, grade: grade!, flag: flag)
    }
    @IBAction func sw(_ sender: Any) {
        changeSectionInHere(index: 4, grade: grade!, flag: flag)
    }
    
    @IBAction func international(_ sender: Any) {
        changeSectionInHere(index: 5, grade: grade!, flag: flag)
    }
    @IBAction func thinking(_ sender: Any) {
        changeSectionInHere(index: 9, grade: grade!, flag: flag)
    }
    @IBAction func global(_ sender: Any) {
        changeSectionInHere(index: 10, grade: grade!, flag: flag)
    }
    
    @IBAction func inAllGrade(_ sender: Any) {
        changeTarget(flag: 0)
    }
    @IBAction func inMyGrade(_ sender: Any) {
        changeTarget(flag: 1)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        segue.destination.transitioningDelegate = self
        segue.destination.modalPresentationStyle = .custom
    }
}

extension CulturalViewController: BonsaiControllerDelegate {
    
    func frameOfPresentedView(in containerViewFrame: CGRect) -> CGRect {

        return CGRect(origin: CGPoint(x: 0, y: allGrade.frame.origin.y), size: CGSize(width: containerViewFrame.width, height: view.frame.size.height - allGrade.frame.origin.y + 49))
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
    
        return BonsaiController(fromDirection: .bottom, backgroundColor: UIColor(white: 0, alpha: 0.0), presentedViewController: presented, delegate: self)
    }
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
