//
//  APIService.swift
//  iKU
//
//  Created by 박재영 on 2021/03/11.
//

import Foundation
import SwiftSoup
import Alamofire
import RxSwift
import RxCocoa

let ud = UserDefaults.standard
var grade = ud.string(forKey: "grade") ?? "1"
let allURL = "https://kupis.konkuk.ac.kr/sugang/acd/cour/aply/CourInwonInqTime.jsp?ltYy=2021&ltShtm=B01011&sbjtId="
let seniorURL = "https://kupis.konkuk.ac.kr/sugang/acd/cour/aply/CourBasketInwonInq.jsp?ltYy=2021&ltShtm=B01011&promShyr=\(grade)&fg=B&sbjtId="

class APIService {
    
    static func findSeats(lecs: [Lecture], url: String) {
        var left: String = " "
        for lec in lecs {
            guard let url = URL(string: url+lec.number) else { return }
            AF.request(url).responseString { (response) in
                switch response.result {
                case .success:
                    do {
                        let html = response.value!
                        let doc: Document = try SwiftSoup.parse(html)
                        let srcs = try doc.select("[align=center]").array()
                        if srcs.count > 1 {
                            let vacant = try srcs[0].text()
                            let max = try srcs[1].text()
                            left = "\(vacant) / \(max)"
                        }
                        else {
                            left = try srcs[0].text()
                        }
                        lec.setLeft(refreshed: left)
                    }
                    catch Exception.Error(_, let message) {
                        print(message)
                    } catch {
                        print("error")
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    func returnTypeName(type: String) -> String {
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
