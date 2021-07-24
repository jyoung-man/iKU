//
//  LectureInfoViewModel.swift
//  iKU
//
//  Created by 박재영 on 2021/07/01.
//

import Foundation
import RxSwift
import RxCocoa

class LectureInfoViewModel {
    var lecName: String?
    var firstGrade: PublishSubject<String> = PublishSubject()
    
}
