//
//  Lecture.swift
//  iKU
//
//  Created by 박재영 on 2021/02/03.
//

import UIKit
import RxDataSources

class Lecture: Decodable, IdentifiableType, Equatable {
    var type: String
    var number: String
    var title: String
    var dept: String
    var prof: String
    var section: String
    var lecInfo: String
    var left: String
    var available: Bool
    var identity: String {
        return number
    }
    
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
    
    init(type:String, number:String, title:String, dept: String, prof:String, section: String, left: String) {
        self.type = type
        self.number = number
        self.title = title
        self.dept = dept
        self.prof = prof
        self.section = section
        self.left = left
        self.available = false
        self.lecInfo = "\(type) \(number) \(title) \(prof) \(section)"
    }
    
    public static func ==(lhs: Lecture, rhs:Lecture) -> Bool {
        return lhs.identity == rhs.identity
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
