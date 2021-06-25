//
//  Department.swift
//  iKU
//
//  Created by 박재영 on 2021/02/08.
//

import UIKit

class Department {
    let d_name: String
    let d_code: String
    
    init(d_name: String, d_code: String) {
        self.d_name = d_name
        self.d_code = d_code
    }
    
    func getName() -> String {
        return self.d_name
    }
    
    func getCode() -> String{
        return self.d_code
    }
}
