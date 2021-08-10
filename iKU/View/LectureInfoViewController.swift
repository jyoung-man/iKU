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
    @IBOutlet weak var note: UILabel!
    @IBOutlet weak var ratio: UIView!
    lazy var att: PublishSubject<String> = PublishSubject()
    var lec_name: String?
    var lec_code: String?
    var lecture = [String]()
    var lectures = [String]()
    var profContact = [String]()
    var f_left: String?
    var entry: [Double] = [1,1,1,1]
    var disposeBag = DisposeBag()
    @IBOutlet weak var backgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pieChart.delegate = self
        titleView.layer.borderWidth = 1
        titleView.layer.borderColor =  CGColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1)
        titleView.layer.cornerRadius = 30
        
        att.map{ $0 }
            .subscribe(onNext: {
                self.attention.text = $0
            }).disposed(by: disposeBag)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pieChart.frame = CGRect(x: 0, y: 0, width: ratio.frame.size.width, height: ratio.frame.size.height)
        //pieChart.frame = ratio.frame
        //pieChart.center = ratio.center
        ratio.addSubview(pieChart)
        
        var entries = [PieChartDataEntry]()
        entries.append(PieChartDataEntry(value: entry[0], label: "1학년"))
        entries.append(PieChartDataEntry(value: entry[1], label: "2학년"))
        entries.append(PieChartDataEntry(value: entry[2], label: "3학년"))
        entries.append(PieChartDataEntry(value: entry[3], label: "4학년"))
        let set = PieChartDataSet(entries: entries, label: "")
        set.colors = ChartColorTemplates.colorful()
        
        let legend = pieChart.legend
        legend.horizontalAlignment = .right
        legend.verticalAlignment = .center
        legend.orientation = .vertical
        
        let data = PieChartData(dataSet: set)
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        data.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        pieChart.data = data
    }

    override func viewWillAppear(_ animated: Bool) {
        lec_code = ad?.selected_lec
        //lec_code = ad?.stack?.peak()
        //lectures = (ad?.stack?.getElements())!
        print(lec_code)
        //print(lectures)
        lecture = DBHelper().askLecInfo(l_number: lec_code!)
        profContact = DBHelper().askProf(l_number: lec_code!)
        nameLabel.text = lecture[0]
        pieChart.animate(xAxisDuration: 1.0, easingOption: .easeOutBack)
        pieChart.drawHoleEnabled = false
        let sc = ud.stringArray(forKey: "stack")
        print(sc)
        let myUrl = "https://kupis.konkuk.ac.kr/sugang/acd/cour/plan/CourLecturePlanInq.jsp?ltYy=2021&ltShtm=B01012&sbjtId=\(lec_code!)"
        RxAlamofire.requestString(.get, URL(string: myUrl)!)
            .subscribe(onNext: { (response, str) in
                let ret = self.reformatContent(article: str)
                self.att.onNext(ret)
                }).disposed(by: disposeBag)
        att.onNext("표시할 내용이 없습니다.")
    }
    
    func reformatContent(article: String) -> String {
        //6번째 "txt_left"> 뒤, </td> 앞
        let splitString = article.components(separatedBy: "\"txt_left\">")    //"\"center\">"
        var result = ["표시할 내용이 없습니다.", "??"]
        if splitString.count > 6{
            result = splitString[6].components(separatedBy: "</td>")
        }
        return result[0]
        
    }
}
