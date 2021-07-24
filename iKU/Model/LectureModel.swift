//
//  LectureModel.swift
//  iKU
//
//  Created by 박재영 on 2021/03/30.
//

import Foundation

struct LectureModel {
    var lecture: Lecture
    
    init(lecture: Lecture) {
        self.lecture = lecture
    }
    
    func setLeft(refreshed: String) {
        lecture.left = refreshed
    }
    
    func setAvailable(flag: Bool) {
        lecture.isAvailable = flag
    }
    
    func getAvailable() -> Bool {
        return lecture.isAvailable
    }
}
