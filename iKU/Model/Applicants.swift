//
//  Applicants.swift
//  iKU
//
//  Created by 박재영 on 2021/07/01.
//

import Foundation

class Applicants {
    var applicant: [String] = []
    
    func addGrade(app: String) {
        applicant.append(app)
    }
    
    func clearApp() {
        applicant.removeAll()
    }
}
