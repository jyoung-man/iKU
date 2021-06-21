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
    
    func mutableLectures(dept: String, type: String) -> BehaviorRelay<[LectureSection]> {
        let subject: BehaviorRelay<[LectureSection]> = BehaviorRelay(value: [])
        let data = DBHelper().askLecture(dept: dept, type: type)
        let depts = [LectureSection(lecType: "나중에 수정해주세요", items: data)]
        subject.accept(depts)
        
        return subject
    }
}
