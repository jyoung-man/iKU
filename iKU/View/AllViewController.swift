//
//  AllViewController.swift
//  iKU
//
//  Created by 박재영 on 2021/02/25.
//
import DropDown
import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import BonsaiController

class AllViewController: UIViewController, UISearchBarDelegate {
    let ad = UIApplication.shared.delegate as? AppDelegate
    let ud = UserDefaults.standard
    let cellID = "lCell"
    private var viewModel: LectureListViewModel!
    var datasource: RxTableViewSectionedReloadDataSource<LectureSection>!
    var disposeBag = DisposeBag()
    var flag: Int = 0
    
    @IBOutlet weak var allGrade: UIButton!
    @IBOutlet weak var myGrade: UIButton!
    @IBOutlet weak var lecSearchBar: UISearchBar!
    @IBOutlet weak var allTableView: UITableView!
    @IBOutlet weak var customBackButton: UIButton!
    @IBOutlet weak var viewNextButton: UIView!
    
    var myDept: String?
    var gradeValue: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        gradeValue = ud.string(forKey: "grade") ?? "1"
        self.viewModel = LectureListViewModel(classes: "type")
        viewNextButton.layer.cornerRadius = 20
        viewNextButton.layer.borderWidth = 1
        viewNextButton.layer.borderColor = CGColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1)
        lecSearchBar.delegate = self
        lecSearchBar.barTintColor = allTableView.backgroundColor
        lecSearchBar.searchTextField.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        
        let dSource = RxTableViewSectionedReloadDataSource<LectureSection>(configureCell: { dSource, allTableView, indexPath, item in
            let cell = allTableView.dequeueReusableCell(withIdentifier: self.cellID, for: indexPath) as! LectureCell
            item.mvvm
                .map{ $0 }
                .subscribe(onNext: {
                    cell.leftLabel.text = $0
                    self.viewModel.makeItRed(cell: cell, left: $0)
                }).disposed(by: cell.disposeBag) //셀이 화면에서 보이지 않을 때는 bind를 풀어줘야 함
            cell.leftLabel.text = item.left
            cell.titleLabel.text = item.title
            cell.profAndNumberLabel.text = "\(item.prof)/\(item.number)"
            self.viewModel.setCellLooks(cell: cell)
            self.viewModel.makeItRed(cell: cell, left: cell.leftLabel.text ?? "0/2")

            return cell
        })
        dSource.titleForHeaderInSection = {ds, index in
            return ds.sectionModels[index].lecType}
        self.datasource = dSource
        
        allTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        viewModel.mutableLectureList()
            .bind(to: allTableView.rx.items(dataSource: datasource))
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
        lecSearchBar.text = ""
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            segue.destination.transitioningDelegate = self
            segue.destination.modalPresentationStyle = .custom
    }
    
    @IBAction func customBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func allGrade(_ sender: Any) {
        self.flag = 0
        viewModel.countSeats(flag: self.flag, myGrade: self.gradeValue ?? "1")
    }
    
    @IBAction func myGrade(_ sender: Any) {
        self.flag = 1
        viewModel.countSeats(flag: self.flag, myGrade: self.gradeValue ?? "1")
    }
    
}

extension AllViewController: BonsaiControllerDelegate {
    
    func frameOfPresentedView(in containerViewFrame: CGRect) -> CGRect {
        return CGRect(origin: CGPoint(x: 0, y: allGrade.frame.origin.y), size: CGSize(width: containerViewFrame.width, height: view.frame.size.height - allGrade.frame.origin.y + 49))
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return BonsaiController(fromDirection: .bottom, backgroundColor: UIColor(white: 0, alpha: 0.0), presentedViewController: presented, delegate: self)
    }
}


extension AllViewController: UITableViewDelegate {
    
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
        viewModel.filterByKeyword(searchText: searchText, flag: 3)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        viewModel.countSeats(flag: self.flag, myGrade: self.gradeValue ?? "1")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
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
