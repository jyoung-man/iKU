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
    var grade: String?
    
    //lazy var findSeatsForAll =
    //lazy var findSeatsForSenior =
    
    init(dept: String, classes: String) {
        lectureSections = APIService().findSection(dept: dept, classes: classes)
        allLecs = APIService().mutableLectures(depts: lectureSections)
        filteredLec = lectures
        //lectureSections = []
    }
    
    func setLectures(lectures: [Lecture]) {
        self.lectures = lectures
    }
    
    func setAllLecs(depts: [LectureSection]) {
        self.allLecs = APIService().mutableLectures(depts: depts)
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
            allLecs.accept([lectureSections[0]])
        }
        else if index == 1 {
            allLecs.accept([lectureSections[1]])
        }
        else if index == 2 {
            allLecs.accept([lectureSections[2]])
        }
        else if index == 3 {
            allLecs.accept([lectureSections[3]])
        }
        else if index == 4 {
            allLecs.accept([lectureSections[4]])
        }
        else if index == 5 {
            allLecs.accept([lectureSections[5]])
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
