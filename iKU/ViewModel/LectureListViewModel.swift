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

    var filteredLec: [LectureSection]!
    var vacantLec: [LectureSection]!
    var searchedLec: [LectureSection]!
    var grade: String?
    
    //lazy var findSeatsForAll =
    //lazy var findSeatsForSenior =
    
    init(dept: String, classes: String) {
        lectureSections = APIService().findSection(dept: dept, classes: classes)
        allLecs = APIService().mutableLectures(depts: lectureSections)
        filteredLec = lectureSections
    }
    
    func setLectures(lectures: [Lecture]) {
        self.lectures = lectures
    }
    
    func setAllLecs(sections: [LectureSection]) {
        self.allLecs = APIService().mutableLectures(depts: sections)
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
                    //vacantLec.append(l)
                }
            }
        }
    }
    
    func filterByKeyword(searchText: String, flag: Bool) {
        var searched = [Lecture]()
        searchedLec = []
        
        if searchText == "" {
            searchedLec = lectureSections
        }
        else {
            var keyword = searchText.components(separatedBy: " ")
            while keyword.count <= 2 {
                keyword.append(keyword[0])
            }
            for s in lectureSections {
                searched.removeAll()
                for lec in s.items {
                    if lec.lecInfo.contains(keyword[0]) && lec.lecInfo.contains(keyword[1]) && lec.lecInfo.contains(keyword[2]) {
                        searched.append(lec)
                    }
                    searchedLec.append(LectureSection(lecType: s.lecType, items: searched))
                }
            }
        }
        
        if flag {
            //filterByLeft(lecs: searchedLec)
        }
        else {
            filteredLec = searchedLec
        }
        
        allLecs.accept(filteredLec)
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
    
    func changeMajor(dept: String) {
        lectureSections = APIService().findSection(dept: dept, classes: "type")
        allLecs.accept(lectureSections)
    }
    func returnNumCode(section: Int, index: Int) -> String {
        return self.filteredLec[section].items[index].number
    }
    
    func returnLecture(section: Int, index: Int) -> Lecture {
        return self.filteredLec[section].items[index]
    }
    
    func returnSize() -> Int {
        return self.filteredLec.count
    }
    
    func mutableLectureList() -> BehaviorRelay<[LectureSection]> {
        return allLecs
    }
}
