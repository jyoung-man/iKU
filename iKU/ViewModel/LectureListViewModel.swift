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
    var culturalLec: [LectureSection]!
    var vacantLec: [LectureSection]!
    var searchedLec: [LectureSection]!
    //lazy var findSeatsForAll =
    //lazy var findSeatsForSenior =
    
    init(classes: String) {
        lectureSections = APIService().findSection(dept: "*", classes: classes)
        allLecs = APIService().mutableLectures(depts: [])
        filteredLec = lectureSections
    }
    
    init(dept: String, classes: String) {
        lectureSections = APIService().findSection(dept: dept, classes: classes)
        allLecs = APIService().mutableLectures(depts: lectureSections)
        filteredLec = lectureSections
        culturalLec = lectureSections
    }
        
    func setLectures(lectures: [Lecture]) {
        self.lectures = lectures
    }
    
    func setAllLecs(sections: [LectureSection]) {
        self.allLecs = APIService().mutableLectures(depts: sections)
    }
    
    func countSeats(flag: Int, myGrade: String){
        APIService().findSeatsByRx(lecs: filteredLec, flag: flag, grade: myGrade)
    }
    
    func countSeatsForOneLec(flag: Int, myGrade: String, section: Int, index: Int) {
        APIService().findSeatsForOneLecByRx(lec: self.filteredLec[section].items[index], flag: flag, grade: myGrade)
    }
    
    func filterByLeft() {
        var vacant = [Lecture]()
        vacantLec = []
        
        var temp: [String]
        var m: Int
        var v: Int
        for lecs in filteredLec {
            for l in lecs.items {
                temp = l.left.components(separatedBy: " / ")
                if temp.count > 1 {
                    v = Int(temp[0])!
                    m = Int(temp[1])!
                    if v < m {
                        vacant.append(l)
                    }
                }
            }
            vacantLec.append(LectureSection(lecType: lecs.lecType, items: vacant
            ))
        }
        allLecs.accept(vacantLec)
    }
    
    func filterByKeyword(searchText: String, flag: Int) {
        var searched = [Lecture]()
        searchedLec = []
        
        if searchText == "" && flag < 3{
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
                }
                if !searched.isEmpty {
                    searchedLec.append(LectureSection(lecType: s.lecType, items: searched))
                }
            }
        }
        
        if flag == 2 {
            //filterByLeft(lecs: searchedLec)
        }
        else {
            filteredLec = searchedLec
        }
        
        allLecs.accept(filteredLec)
    }
    
    func changeCulturalSection(index: Int, grade: String, flag: Int){
        lectureSections = culturalLec
        if index == 0 {
            lectureSections = [lectureSections[0]]
        }
        else if index == 1 {
            lectureSections = [lectureSections[1]]
        }
        else if index == 2 {
            lectureSections = [lectureSections[2]]
        }
        else if index == 3 {
            lectureSections = [lectureSections[3]]
        }
        else if index == 4 {
            lectureSections = [lectureSections[4]]
        }
        else if index == 5 {
            lectureSections = [lectureSections[5], lectureSections[6], lectureSections[7]]
        }
        else if index == 6 {
            lectureSections = [lectureSections[6]]
        }
        else if index == 7 {
            lectureSections = [lectureSections[7]]
        }
        else if index == 8 {
            lectureSections = [lectureSections[8]]
        }
        else if index == 9 {
            lectureSections = [lectureSections[9]]
        }
        else if index == 10 {
            lectureSections = [lectureSections[10]]
        }
        else {
            print("Out of index")
        }
        filteredLec = lectureSections
        countSeats(flag: flag, myGrade: grade)
        allLecs.accept(filteredLec)
    }
    
    func changeMajor(dept: String) {
        lectureSections = APIService().findSection(dept: dept, classes: "type")
        allLecs.accept(lectureSections)
        filteredLec = lectureSections
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
