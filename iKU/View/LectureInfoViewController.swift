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

class LectureInfoViewController: UIViewController, ChartViewDelegate {
    let ad = UIApplication.shared.delegate as? AppDelegate
    let viewModel = LectureInfoViewModel()
    var pieChart = PieChartView()
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var titleView: UIView!
    var lec_name: String? = "선형대수"
    var lec_code: String? = "0032"
    var lecture: Lecture?
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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pieChart.bounds = CGRect(x: 0, y: -80, width: self.view.frame.size.width*2/3, height: self.view.frame.size.width*2/3)
        pieChart.center = backgroundView.center
        backgroundView.addSubview(pieChart)
        
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
        lecture = ad?.selected_lecture!
        nameLabel.text = lecture?.title
        pieChart.animate(xAxisDuration: 1.0, easingOption: .easeOutBack)
        pieChart.drawHoleEnabled = false
    }
}
