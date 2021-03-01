//
//  LectureInfo.swift
//  iKU
//
//  Created by 박재영 on 2021/02/14.
//

import UIKit

class LectureInfo: Lecture {
    var credit: Int32
    var time: String
    var classroom: String
    var untact: String
    var note: String

    init(lec: Lecture, credit: Int32, time: String, classroom: String, untact: String, note: String) {
        self.credit = credit
        self.time = time
        self.classroom = classroom
        self.untact = untact
        self.note = note
        super.init(lec: lec)
    }
}
