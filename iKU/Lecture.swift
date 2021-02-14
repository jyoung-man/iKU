//
//  Lecture.swift
//  iKU
//
//  Created by 박재영 on 2021/02/03.
//

import UIKit

class Lecture {
    var type: String
    var number: String
    var title: String
    var credit: Int32
    var dept: String
    var time: String
    var prof: String
    var untact: String
    var note: String
    var section: String
    var lecInfo: String
    var available: String
    init(type:String, number:String, title:String, credit: Int32, dept: String, time:String, prof:String, untact: String, note: String, section: String) {
        self.type = type
        self.number = number
        self.title = title
        self.credit = credit
        self.dept = dept
        self.time = time
        self.prof = prof
        self.untact = untact
        self.note = note
        self.section = section
        self.available = ""
        self.lecInfo = "\(type) \(number) \(title) \(prof) \(section)"
    }
    
    func setAvailable(refreshed: String) {
        self.available = refreshed
    }
    
}
