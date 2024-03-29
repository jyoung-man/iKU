//
//  APIService.swift
//  iKU
//
//  Created by 박재영 on 2021/03/11.
//

import Foundation
import RxSwift
import RxCocoa
import RxAlamofire

class APIService {
    let disposeBag = DisposeBag()
    
    func findSeatsByRx(lecs: [LectureSection], flag: Int, grade: String) {
        var myUrl: String = ""
        
        for s in lecs {
            for l in s.items {
                if flag == 0 { //전체
                    myUrl = "https://kupis.konkuk.ac.kr/sugang/acd/cour/aply/CourInwonInqTime.jsp?ltYy=2021&ltShtm=B01012&sbjtId=\(l.number)"
                    
                    RxAlamofire.requestString(.get, URL(string: myUrl)!)
                        .subscribe(onNext: { (response, str) in
                            let ret = self.reformatString(article: str)
                            l.mvvm.onNext(ret)
                            l.left = ret
                        }).disposed(by: disposeBag)
                    l.mvvm.onNext("조회 중...")
                }
                else if flag == 1 { //학년별
                    myUrl = "https://kupis.konkuk.ac.kr/sugang/acd/cour/aply/CourBasketInwonInq.jsp?ltYy=2021&ltShtm=B01012&promShyr=\(grade)&fg=B&sbjtId=\(l.number)"
                    
                    RxAlamofire.requestString(.get, URL(string: myUrl)!)
                        .subscribe(onNext: { (response, str) in
                            let ret = self.reformatString(article: str)
                            l.mvvm.onNext(ret)
                            l.left = ret
                        }).disposed(by: disposeBag)
                    l.mvvm.onNext("조회 중...")
                }
            }
        }
    }
    
    func findSeatsForOneLecByRx(lec: Lecture, flag: Int, grade: String) {
        var myUrl: String = ""

        if flag == 0 { //전체
            myUrl = "https://kupis.konkuk.ac.kr/sugang/acd/cour/aply/CourInwonInqTime.jsp?ltYy=2021&ltShtm=B01012&sbjtId=\(lec.number)"
        }
        else if flag == 1 { //학년별
            myUrl = "https://kupis.konkuk.ac.kr/sugang/acd/cour/aply/CourBasketInwonInq.jsp?ltYy=2021&ltShtm=B01012&promShyr=\(grade)&fg=B&sbjtId=\(lec.number)"
        }
        
        RxAlamofire.requestString(.get, URL(string: myUrl)!)
            .subscribe(onNext: { (response, str) in
                let ret = self.reformatString(article: str)
                lec.mvvm.onNext(ret)
                lec.left = ret
                }).disposed(by: disposeBag)
        lec.mvvm.onNext("조회 중...")
    }

    
    func reformatString(article: String) -> String {
        var ret: String = ""
        var html = article
        var lefts = [String]()

        while let range = html.range(of: "\"center\">") {
            html = String(html[html.index(after: range.lowerBound)...])
            let value = html[html.startIndex...html.index(html.startIndex, offsetBy: 15)]
            lefts.append(String(value))
        }
        if lefts.count > 1 {
            var temp = lefts[0].components(separatedBy: ">")
            let vac = temp[1].components(separatedBy: "<")
            temp = lefts[1].components(separatedBy: ">")
            let max = temp[1].components(separatedBy: "<")
            ret = "\(vac[0]) / \(max[0])"
        }
        else if lefts.count > 0 {
            let temp = lefts[0].components(separatedBy: ">")
            let vac = temp[1].components(separatedBy: "<")
            ret = "\(vac[0])"
        }
        
        return ret
    }
    
    func returnTypeName(type: String) -> String {
        switch type {
        case "기교":
            return "기초교양"
        case "심교":
            return "심화교양"
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
    
    func findSection(dept: String, classes: String) -> [LectureSection] {
        let types = DBHelper().askTypeOrSection(dept: dept, target: classes)
        var lectureSections: [LectureSection] = []
        var lectures: [Lecture]
        for type in types {
            lectures = DBHelper().askLecture(dept: dept, type: type)
            if !lectures.isEmpty {
                lectureSections.append(LectureSection(lecType: returnTypeName(type: type), items: lectures))
                print(type)
            }
        }

        return lectureSections
    }

    
    func findLecInOneSec(dept: String, type: String) -> [LectureSection] {
        var lectureSections: [LectureSection] = []
        let lectures = DBHelper().askLecture(dept: dept, type: type)
        lectureSections.append(LectureSection(lecType: returnTypeName(type: type), items: lectures))
        return lectureSections
    }
    
    func mutableLectures(depts: [LectureSection]) -> BehaviorRelay<[LectureSection]> {
        let subject: BehaviorRelay<[LectureSection]> = BehaviorRelay(value: [])
        subject.accept(depts)
        
        return subject
    }
}
