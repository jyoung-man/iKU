//
//  LectureInfoViewController.swift
//  iKU
//
//  Created by 박재영 on 2021/06/26.
//

import UIKit
import Charts
import RxSwift
import RxCocoa
import RxAlamofire

class LectureInfoViewController: UIViewController, ChartViewDelegate {
    let ad = UIApplication.shared.delegate as? AppDelegate
    let ud = UserDefaults.standard

    let viewModel = LectureInfoViewModel()
    var pieChart = PieChartView()
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var attention: UILabel!
    
    @IBOutlet weak var type_number: UILabel!
    
    @IBOutlet weak var time: UILabel!
    
    @IBOutlet weak var credit: UILabel!
    
    @IBOutlet weak var classroom: UILabel!
    
    @IBOutlet weak var professor: UILabel!
    
    @IBOutlet weak var laboratory: UILabel!
    
    @IBOutlet weak var email: UILabel!
    
    @IBOutlet weak var timeLocationView: UIView!
    
    @IBOutlet weak var professorView: UIView!
    
    @IBOutlet weak var noteView: UIView!
    
    @IBOutlet weak var note: UILabel!
    
    @IBOutlet weak var ratio: UIView!
    
    lazy var att: PublishSubject<String> = PublishSubject()
    var lec_name: String?
    var lec_code: String?
    var lecture = [String]()
    var profContact = [String]()
    var entry: [Double] = [1,1,1,1]
    var disposeBag = DisposeBag()
    @IBOutlet weak var backgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pieChart.delegate = self
        setBorder(view: titleView)
        setBorder(view: timeLocationView)
        setBorder(view: professorView)
        setBorder(view: noteView)
        
        attention.lineBreakMode = .byWordWrapping
        att.map{ $0 }
            .subscribe(onNext: {
                self.attention.text = $0
            }).disposed(by: disposeBag)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pieChart.frame = CGRect(x: ratio.frame.size.width/8, y: 0, width: ratio.frame.size.width*3/4, height: ratio.frame.size.width/2)
        //pieChart.frame = ratio.frame
        //pieChart.center = ratio.center
        ratio.addSubview(pieChart)
        
        pieChart.data = viewModel.setPieChart(pieChart: pieChart)
    }

    override func viewWillAppear(_ animated: Bool) {
        lec_code = ad?.selected_lec
        lecture = DBHelper().askLecInfo(l_number: lec_code!)
        profContact = DBHelper().askProf(l_number: lec_code!)
        nameLabel.text = lecture[0]
        let type = lecture[2]
        type_number.text = "\(APIService().returnTypeName(type: type))/\(lecture[9])/\(lecture[1])"
        time.text = lecture[4]
        credit.text = lecture[3]
        let location = lecture[5].replacingOccurrences(of: "/", with: "\n")
        classroom.text = location
        note.text = lecture[7]
        note.lineBreakMode = .byWordWrapping
        professor.text = lecture[9]

        if !profContact.isEmpty{
            laboratory.text = profContact[2]
            email.text = profContact[1]
        }
        
        
        
        pieChart.animate(xAxisDuration: 1.0, easingOption: .easeOutBack)
        pieChart.drawHoleEnabled = false
        let sc = ud.stringArray(forKey: "stack")
        let encoding = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(0x0422))

        let myUrl = "https://kupis.konkuk.ac.kr/sugang/acd/cour/plan/CourLecturePlanInq.jsp?ltYy=2021&ltShtm=B01012&sbjtId=\(lec_code!)"
        RxAlamofire.requestData(.get, URL(string: myUrl)!)
            .subscribe(onNext: { (response, data) in
                let article = String(data: data, encoding: String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(0x0422))) ?? "표시할 내용이 없습니다."
                let ret = self.reformatContent(article: article)
                self.att.onNext(ret)
                }).disposed(by: disposeBag)
        att.onNext("표시할 내용이 없습니다.")
    }
    
    func reformatContent(article: String) -> String {
        //6번째 "txt_left"> 뒤, </td> 앞
        let splitString = article.components(separatedBy: "\"txt_left\">")    //"\"center\">"
        var result = ["표시할 내용이 없습니다.", "??"]
        if splitString.count > 6{
            result = splitString[5].components(separatedBy: "</th>")
        }
        return result[0]
        
    }
    
    func setBorder(view: UIView) {
        view.layer.borderWidth = 1
        view.layer.borderColor =  CGColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1)
        view.layer.cornerRadius = 20
    }
}
