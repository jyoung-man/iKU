//
//  MainViewController.swift
//  iKU
//
//  Created by 박재영 on 2021/08/07.
//

import UIKit
import RxSwift
import RxAlamofire

class MainViewController: UIViewController {

    @IBOutlet weak var myMajorLabel: UILabel!
    @IBOutlet weak var myMajorButton: UIButton!
    @IBOutlet weak var first_dabuButton: UIButton!
    @IBOutlet weak var first_dabuLabel: UILabel!
    @IBOutlet weak var second_dabuLabel: UILabel!
    @IBOutlet weak var second_dabuButton: UIButton!
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var majorBarView: UIView!
    @IBOutlet weak var myGradeLabel: UILabel!
    @IBOutlet weak var recentTableView: UITableView!
    @IBOutlet weak var kuImg: UIButton!
    
    let ad = UIApplication.shared.delegate as? AppDelegate
    let ud = UserDefaults.standard
    lazy var mvvm: [PublishSubject<String>] = [PublishSubject(), PublishSubject(), PublishSubject(), PublishSubject(), PublishSubject()]
    var disposeBag = DisposeBag()
    var recent = [String]()
    var lectures = [[String]]()
    var left: [String] = ["","","","",""]
    var grade_info: String?
    var flag: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setStack()
        recentTableView.dataSource = self
        recentTableView.delegate = self
        recentTableView.layer.cornerRadius = 20
        searchBarView.layer.cornerRadius = 20
        majorBarView.layer.cornerRadius = 20
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let mj_info = ud.string(forKey: "mj_info")?.split(separator: " ")
        let dm_info = ud.string(forKey: "dm_info")?.split(separator: " ")
        let sm_info = ud.string(forKey: "sm_info")?.split(separator: " ")
        myMajorLabel.text = String((mj_info?[1])!)
        first_dabuLabel.text = String((dm_info?[1]) ?? "선택")
        second_dabuLabel.text = String((sm_info?[1]) ?? "선택")
        myGradeLabel.text = grade_info! + "학년"
        kuImg.setBackgroundImage(UIImage(named: self.myGradeLabel.text ?? "3학년"), for: .normal)
        setStack()
        if recent.count > 0{
            findSeatsForHereByRx(code: recent, flag: self.flag, grade: self.grade_info!)
            let indexPath = NSIndexPath(row: NSNotFound, section: 0)
            self.recentTableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: false)
        }
        recentTableView.reloadData()
    }
    
    func setStack() {
        recent = ud.stringArray(forKey: "stack") ?? []
        grade_info = ud.string(forKey: "grade")
        lectures = []
        for r in recent.reversed() {
            let lecture = DBHelper().askLecInfo(l_number: r)
            lectures.append(lecture)
        }

    }
    
    func setButtonAttribute(button: UIButton) {
        button.layer.borderWidth = 1.0
        button.layer.borderColor = CGColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1)
    }
    @IBAction func gotoRoot(_ sender: Any) {
        _ = navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func goBack1(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func goBack2(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func goBack3(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func findSeatsForHereByRx(code: [String], flag: Int, grade: String) {
        var myUrl: String = ""
        for i in 0...(code.count-1) {
            if flag == 0 { //전체
                myUrl = "https://kupis.konkuk.ac.kr/sugang/acd/cour/aply/CourInwonInqTime.jsp?ltYy=2021&ltShtm=B01012&sbjtId=\(code[i])"
            }
            else if flag == 1 { //학년별
                myUrl = "https://kupis.konkuk.ac.kr/sugang/acd/cour/aply/CourBasketInwonInq.jsp?ltYy=2021&ltShtm=B01012&promShyr=\(grade)&fg=B&sbjtId=\(code[i])"
            }

            RxAlamofire.requestString(.get, URL(string: myUrl)!)
                .subscribe(onNext: { (response, str) in
                    let ret = APIService().reformatString(article: str)
                    self.mvvm[i].onNext(ret)
                    self.left[i] = ret
                }).disposed(by: self.disposeBag)
            self.mvvm[i].onNext("조회 중...")
        }
    }
    
    func changeTarget(flag: Int) {
        findSeatsForHereByRx(code: recent, flag: flag, grade: self.grade_info!)
        self.flag = flag
    }
    
    @IBAction func inAllGrade(_ sender: Any) {
        changeTarget(flag: 0)
    }
    @IBAction func inMyGrade(_ sender: Any) {
        changeTarget(flag: 1)
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recent.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? LectureCell else { return }
        cell.disposeBag = DisposeBag()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = recentTableView.dequeueReusableCell(withIdentifier: "lCell") as! LectureCell

        self.mvvm[indexPath.row]
            .map{ $0 }
            .subscribe(onNext: {
                cell.leftLabel.text = $0
            }).disposed(by: cell.disposeBag) //셀이 화면에서 보이지 않을 때는 bind를 풀어줘야 함
        cell.titleLabel.text = lectures[indexPath.row][0]
        cell.profAndNumberLabel.text = "\(lectures[indexPath.row][9])/\(lectures[indexPath.row][1])"
        cell.leftLabel.text = left[indexPath.row]
        
        cell.lecCellView.layer.borderWidth = 1
        cell.lecCellView.layer.borderColor = CGColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1)
        cell.lecCellView.layer.cornerRadius = cell.lecCellView.frame.height / 3
        
        return cell
    }
    

}
