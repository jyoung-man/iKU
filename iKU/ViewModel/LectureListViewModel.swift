//
//  LectureListViewModel.swift
//  iKU
//
//  Created by 박재영 on 2021/03/30.
//

import Foundation
import RxSwift
import RxCocoa

class LectureListViewModel {
    var allLecs: BehaviorRelay<[LectureSection]>
    var lectureSections: [LectureSection]
    var lectures: [Lecture]!
    var disposeBag = DisposeBag()

    var filteredLec: [Lecture]!
    var vacantLec: [Lecture]!
    var searchedLec: [Lecture]!
    var myDept: String?
    var grade: String?
    
    //lazy var findSeatsForAll =
    //lazy var findSeatsForSenior =
    
    init() {
        //lectures를 Observable로 만들어야 함
        lectures = DBHelper().askLecture(dept: "B0404P", type: "외국어&글쓰기")
        allLecs = APIService().mutableLectures(dept: "B0404P", type: "외국어&글쓰기")
        filteredLec = lectures
        lectureSections = []
    }
    
    func setLectures(lectures: [Lecture]) {
        self.lectures = lectures
    }
    
    func setAllLecs(dept:String, type:String) {
        self.allLecs = APIService().mutableLectures(dept: dept, type: type)
    }
    
    func findSection(dept: String) -> [LectureSection] {
        let types = DBHelper().askType(dept: dept)
        
        for type in types {
            lectures = DBHelper().askLecture(dept: dept, type: type)
            lectureSections.append(LectureSection(lecType: type, items: lectures))
        }
        
        return lectureSections
        //남은 할 일: 교양은 영역이 두 개 뿐인데 교양 과목의 섹션을 어떻게 처리할 것인지에 대한 고민
    }
    
    
    func findLecture(dept: String, type: String) -> [LectureSection] {
        let types = ["지교","지필","전필","전선","교직","일선"]
        var lecSec: [LectureSection] = []
        
        if dept=="B0404P" { //교양 과목 조회
            lectures = DBHelper().askLecture(dept: dept, type: type)
            lecSec.append(LectureSection(lecType: type, items: lectures))
        }
        else { //전공 과목 조회
            for t in types {
                lectures = DBHelper().askLecture(dept: dept, type: t)
                if !lectures.isEmpty {
                    lecSec.append(LectureSection(lecType: returnTypeName(type: t), items: lectures))
                }
            }
        }
        return lecSec
        
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
            return ""
        }
    }
    
    func countSeats(lec: Lecture, flag: Int){

    }
    
    func howManySeats(left: String) -> String {
        let vacant: Int?
        let temp = left.components(separatedBy: " / ")
        if temp.count < 2 {
            return " "
        }
        else {
            let v = temp.map({ (value : String) -> Int in return Int(value)! })
            vacant = v[1] - v[0]
        }
        if vacant! <= 0 {
            return "인원초과"
        }
        else {
            return String(vacant!) + "자리"
        }
    }
    
    func filterByLeft(lecs: [Lecture]) {
        vacantLec = []
        var temp: [String]
        var m: Int
        var v: Int
        for l in lecs {
            temp = l.left.components(separatedBy: " / ")
            if temp.count > 1 {
                v = Int(temp[0])!
                m = Int(temp[1])!
                if v < m {
                    vacantLec.append(l)
                }
            }
        }
    }
    
    func filterByKeyword(searchText: String, flag: Bool) {
        searchedLec = []
        
        if searchText == "" {
            searchedLec = lectures
        }
        else {
            var keyword = searchText.components(separatedBy: " ")
            while keyword.count <= 2 {
                keyword.append(keyword[0])
            }
            
            for lec in lectures {
                if lec.lecInfo.contains(keyword[0]) && lec.lecInfo.contains(keyword[1]) && lec.lecInfo.contains(keyword[2]) {
                    searchedLec.append(lec)
                }
            }
        }
        
        if flag {
            filterByLeft(lecs: searchedLec)
        }
        else {
            filteredLec = searchedLec
        }
        allLecs.accept([LectureSection(lecType: "나중에 수정해주세요", items: filteredLec)])
    }
    
    func changeCulturalSection(index: Int){
        if index == 0 {
            allLecs.accept(findLecture(dept: "B0404P", type: "외국어&글쓰기"))
        }
        else if index == 1 {
            allLecs.accept(findLecture(dept: "B0404P", type: "SW&취창업&인성"))
        }
        else if index == 2 {
            allLecs.accept(findLecture(dept: "B0404P", type: "외국인글쓰기&한국어&사고와표현"))
        }
        else if index == 3 {
            allLecs.accept(findLecture(dept: "B0404P", type: "사고력증진"))
        }
        else if index == 4 {
            allLecs.accept(findLecture(dept: "B0404P", type: "학문소양및인성함양"))
        }
        else if index == 5 {
            allLecs.accept(findLecture(dept: "B0404P", type: "글로벌인재양성"))
        }
        else {
            print("Out of index")
        }
    }
    
    func returnNumCode(index: Int) -> String {
        return self.filteredLec[index].number
    }
    
    func returnSize() -> Int {
        return self.filteredLec.count
    }
    
    func mutableLectureList() -> BehaviorRelay<[LectureSection]> {
        return allLecs
    }
}
