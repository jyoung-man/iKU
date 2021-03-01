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
    var dept: String
    var prof: String
    var section: String
    var lecInfo: String
    var left: String
    var available: Bool
    
    init(type:String, number:String, title:String, dept: String, prof:String, section: String) {
        self.type = type
        self.number = number
        self.title = title
        self.dept = dept
        self.prof = prof
        self.section = section
        self.left = ""
        self.available = false
        self.lecInfo = "\(type) \(number) \(title) \(prof) \(section)"
    }
    
    func setLeft(refreshed: String) {
        self.left = refreshed
    }
    
    func setAvailable(flag: Bool) {
        self.available = flag
    }
    
    func getAvailable() -> Bool {
        return self.available
    }
}
