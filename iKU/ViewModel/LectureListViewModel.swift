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
    let ud = UserDefaults.standard
    let ad = UIApplication.shared.delegate as? AppDelegate
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
        searchedLec = lectureSections
    }
    
    init(dept: String, classes: String) {
        lectureSections = APIService().findSection(dept: dept, classes: classes)
        allLecs = APIService().mutableLectures(depts: lectureSections)
        filteredLec = lectureSections
        culturalLec = lectureSections
        searchedLec = lectureSections
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
    
    func filterByLeft(isActivated: Bool, flag: Int) {
        if isActivated {
            var vacant = [Lecture]()
            vacantLec = []

            for lecs in filteredLec {
                for l in lecs.items {
                    if isAvailable(left: l.left) {
                        vacant.append(l)
                    }
                }
                vacantLec.append(LectureSection(lecType: lecs.lecType, items: vacant))
            }
            filteredLec = vacantLec
        }
        else {
            filteredLec = searchedLec
        }
        allLecs.accept(filteredLec)
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
        filteredLec = searchedLec
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
        searchedLec = lectureSections
        countSeats(flag: flag, myGrade: grade)
        allLecs.accept(filteredLec)
    }
    func getCultureSectionInfo() -> [String] {
        var info: [String] = []
        var type = filteredLec[0].items[0].type
        type = APIService().returnTypeName(type: type)
 
        info.append(type)
        info.append(filteredLec[0].items[0].section)
        
        return info
    }
    
    func changeMajor(dept: String) {
        lectureSections = APIService().findSection(dept: dept, classes: "type")
        allLecs.accept(lectureSections)
        filteredLec = lectureSections
    }
    
    func setCellLooks(cell: LectureCell) {
        cell.lecCellView.layer.borderWidth = 1
        cell.lecCellView.layer.borderColor = CGColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1)
        cell.lecCellView.layer.cornerRadius = cell.lecCellView.frame.height / 3
        cell.lecCellView.layer.masksToBounds = true
        cell.shadowLayer.layer.cornerRadius = cell.lecCellView.frame.height / 3
        cell.shadowLayer.layer.masksToBounds = false
        cell.shadowLayer.layer.shadowOffset = CGSize(width: 0, height: 10)
        cell.shadowLayer.layer.shadowColor = UIColor.black.cgColor
        cell.shadowLayer.layer.shadowOpacity = 0.03
        cell.shadowLayer.layer.shadowRadius = cell.lecCellView.frame.height / 3
        cell.shadowLayer.layer.shadowPath = UIBezierPath(roundedRect: cell.shadowLayer.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 2, height: 1)).cgPath
        cell.shadowLayer.layer.shouldRasterize = true
        cell.shadowLayer.layer.rasterizationScale = UIScreen.main.scale
    }
    
    func returnNumCode(section: Int, index: Int) {
        let selected_lec =  self.filteredLec[section].items[index].number
        ad?.selected_lec = selected_lec
        var stack = ud.stringArray(forKey: "stack") ?? []
        if stack.count >= 5 {
            stack.removeFirst()
        }
        stack.append(selected_lec)
        ud.set(stack, forKey: "stack")
    }
    
    func isAvailable(left: String) -> Bool {
        let vacant: Int?
        let temp = left.components(separatedBy: " / ")
        if temp.count < 2 {
            return true
        }
        else {
            let v = temp.map({ (value : String) -> Int in return Int(value)! })
            vacant = v[1] - v[0]
        }
        if vacant! <= 0 {
            return false
        }
        else {
            return true
        }
    }
    
    func makeItRed(cell: LectureCell, left: String) {
        let flag = isAvailable(left: left)
        if flag {
            cell.titleLabel.textColor = .black
            cell.leftLabel.textColor = .black
            cell.profAndNumberLabel.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 0.5)
        }
        else {
            cell.titleLabel.textColor = UIColor(red: 201/255, green: 28/255, blue: 28/255, alpha: 1)
            cell.leftLabel.textColor = UIColor(red: 201/255, green: 28/255, blue: 28/255, alpha: 1)
            cell.profAndNumberLabel.textColor = UIColor(red: 201/255, green: 28/255, blue: 28/255, alpha: 1)
        }
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
