//
//  LectureStack.swift
//  iKU
//
//  Created by 박재영 on 2021/08/09.
//

import Foundation

class LectureStack {
    private var elements: [String] = []
    
    public func push(_ element: String) {
        if self.elements.count == 5 {
            self.elements.removeFirst()
        }
        self.elements.append(element)
    }
    
    public func pop() -> String {
        return self.elements.popLast()!
    }
    
    public func peak() -> String {
        return self.elements.last!
    }
    
    public func getElements() -> [String] {
        return self.elements
    }
    
    public func replace(array: [String]) {
        for i in array {
            self.push(i)
        }
    }
}
