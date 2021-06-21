//
//  LectureSection.swift
//  iKU
//
//  Created by 박재영 on 2021/03/30.
//

import Foundation
import RxDataSources

struct LectureSection {
    var lecType: String
    var items: [Lecture]
}

extension LectureSection: AnimatableSectionModelType {

    typealias Item = Lecture
    
    var identity: String {
        return lecType
    }
    
    init(original: LectureSection, items: [Lecture]) {
        self = original
        self.items = items
    }
}
