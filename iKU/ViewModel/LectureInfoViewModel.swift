//
//  LectureInfoViewModel.swift
//  iKU
//
//  Created by 박재영 on 2021/07/01.
//

import Foundation
import RxAlamofire
import RxSwift
import RxCocoa
import Charts

class LectureInfoViewModel {
    let ad = UIApplication.shared.delegate as? AppDelegate
    let ud = UserDefaults.standard

    var lecName: String?
    var att: PublishSubject<String> = PublishSubject()
    var lecture = [String]()
    var profContact = [String]()
    var entry: [Double] = [1,1,1,1]
    var disposeBag = DisposeBag()
//   var lec_code: String =
//    init() {
//        lec_code = ad?.selected_lec
//        lecture = DBHelper().askLecInfo(l_number: lec_code)
//        profContact = DBHelper().askProf(l_number: lec_code)
//    }
    
    func setPieChart(pieChart: PieChartView) -> PieChartData {
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
        
        return data
    }
    
    func dataRequest(lec_code: String) -> PublishSubject<String> {
        let sc = ud.stringArray(forKey: "stack")
        let encoding = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(0x0422))

        let myUrl = "https://kupis.konkuk.ac.kr/sugang/acd/cour/plan/CourLecturePlanInq.jsp?ltYy=2021&ltShtm=B01012&sbjtId=\(lec_code)"
        RxAlamofire.requestData(.get, URL(string: myUrl)!)
            .subscribe(onNext: { (response, data) in
                let article = String(data: data, encoding: String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(0x0422))) ?? "표시할 내용이 없습니다."
                let ret = self.reformatContent(article: article)
                self.att.onNext(ret)
                }).disposed(by: disposeBag)
        att.onNext("표시할 내용이 없습니다.")
        return att
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
    
    func reformatTypeName(type: String) -> String {
        switch type {
        case "지교":
            return "지정교양"
        case "지필":
            return "지정필수"
        case "전필":
            return "전공필수"
        case "전선":
            return "전공선택"
        case "교직":
            return "교직이수"
        case "일선":
            return "일반선택"
        default:
            return type
        }
    }
    
//    func returnName() -> String {
//        return self.lecture[0]
//    }
//
//    func returnTypeNumber() -> String {
//        let type = lecture[2]
//        let result = "\(reformatTypeName(type: type))/\(lecture[9])\(lecture[1])"
//
//        return result
//    }
//
//    func returnTime() -> String {
//        return lecture[4]
//    }
//
//    func returnCredit() -> String {
//        return lecture[3]
//    }
//
//    func returnLocation() -> String {
//        let location = lecture[5].replacingOccurrences(of: "/", with: "\n")
//        return location
//    }
//
//    func returnNote() -> String {
//        return lecture[7]
//    }
//
//    func returnProfessor() -> String {
//        return lecture[9]
//    }
//
//    func returnLab() -> String {
//        return profContact[2]
//    }
//
//    func returnEmail() -> String {
//        return profContact[1]
//    }
}
