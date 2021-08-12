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
    
    var lectures: [Lecture]!
    var vacantLec: [Lecture]!
    var searchedLec: [Lecture]!
    var myDept: String?
    var grade: String?
    var stack: [String]?
    var flag: Int = 0
    
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
                    }).disposed(by: cell.disposeBag) 
                cell.leftLabel.text = item.left
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
        
        viewModel.changeCulturalSection(index: 3, grade: grade!, flag: flag)

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
        stack = ud.stringArray(forKey: "stack") ?? []
    }
    @IBAction func startup(_ sender: Any) {
        viewModel.changeCulturalSection(index: 0, grade: grade!, flag: flag)
    }
    
    @IBAction func volunteer(_ sender: Any) {
        viewModel.changeCulturalSection(index: 1, grade: grade!, flag: flag)
    }
    
    @IBAction func language(_ sender: Any) {
        viewModel.changeCulturalSection(index: 2, grade: grade!, flag: flag)
    }
    
    @IBAction func writing(_ sender: Any) {
        viewModel.changeCulturalSection(index: 3, grade: grade!, flag: flag)
    }
    @IBAction func omg(_ sender: Any) {
        viewModel.changeCulturalSection(index: 8, grade: grade!, flag: flag)
    }
    @IBAction func sw(_ sender: Any) {
        viewModel.changeCulturalSection(index: 4, grade: grade!, flag: flag)
    }
    
    @IBAction func international(_ sender: Any) {
        viewModel.changeCulturalSection(index: 5, grade: grade!, flag: flag)
    }
    @IBAction func thinking(_ sender: Any) {
        viewModel.changeCulturalSection(index: 9, grade: grade!, flag: flag)
    }
    @IBAction func global(_ sender: Any) {
        viewModel.changeCulturalSection(index: 10, grade: grade!, flag: flag)
    }
    
    @IBAction func inAllGrade(_ sender: Any) {
        self.lecSearchBar.searchTextField.text = ""
        viewModel.filterByKeyword(searchText: "", flag: 0)
        viewModel.countSeats(flag: 0, myGrade: grade!)
        self.flag = 0
    }
    @IBAction func inMyGrade(_ sender: Any) {
        self.lecSearchBar.searchTextField.text = ""
        viewModel.filterByKeyword(searchText: "", flag: 1)
        viewModel.countSeats(flag: 1, myGrade: grade!)
        self.flag = 1
    }
    
    @IBAction func vacantOnly(_ sender: Any) {
        viewModel.filterByLeft()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        //if segue.destination is HalfSizeViewController {
            segue.destination.transitioningDelegate = self
            segue.destination.modalPresentationStyle = .custom
        //}
    }
}

extension CulturalViewController: BonsaiControllerDelegate {
    
    func frameOfPresentedView(in containerViewFrame: CGRect) -> CGRect {
        
        return CGRect(origin: CGPoint(x: 0, y: allGrade.frame.origin.y), size: CGSize(width: containerViewFrame.width, height: view.frame.size.height - allGrade.frame.origin.y))
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
