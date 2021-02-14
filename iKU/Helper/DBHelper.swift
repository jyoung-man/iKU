//
//  DBHelper.swift
//  iKU
//
//  Created by 박재영 on 2021/02/04.
//

import Foundation
import SQLite3

class DBHelper {
        
    var db : OpaquePointer?
    var path : String = "iku.sqlite"
    init() {
        self.db = copyDatabaseIfNeeded()
    }
    
    func copyDatabaseIfNeeded() -> OpaquePointer?{ //도큐먼트 폴더에 있는 DB를 찾고, 없으면 번들에서 도큐먼트 폴더로 DB를 옮겨주는 함수
        let fileManager = FileManager.default
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
    
        guard documentsUrl.count != 0 else {
            return nil  // Could not find documnets URL
        }
    
        let finalDatabaseURL = documentsUrl.first!.appendingPathComponent(path)
        
        if !((try? finalDatabaseURL.checkResourceIsReachable()) ?? false) {
            print("DB does not exist in documents folder")
            
            let documentsURL = Bundle.main.resourceURL?.appendingPathComponent(path)
            
            do {
                try fileManager.copyItem(atPath: (documentsURL?.path)!, toPath: finalDatabaseURL.path)
            }catch let error as NSError {
                    print("Couldn't copy file to final location! Error:\(error.description)")
                return nil
            }
            if sqlite3_open(finalDatabaseURL.path, &db) == SQLITE_OK {
                print("Succesfully create Database path : \(finalDatabaseURL.path)")
                return db
            }
                
        } else {
            print("Database file found at path: \(finalDatabaseURL.path)")
            if sqlite3_open(finalDatabaseURL.path, &db) == SQLITE_OK {
                print("Succesfully create Database path : \(finalDatabaseURL.path)")
                return db
            }
        }
        return nil
    }
    
    func askDept() -> [Department] {
        let query = "select * from dept"
        var statement : OpaquePointer? = nil
        var depts = [Department]()
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let d_name = String(cString: sqlite3_column_text(statement, 0))
                let d_code = String(cString: sqlite3_column_text(statement, 1))
                depts.append(Department(d_name: d_name, d_code: d_code))
            }
        }
        else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("\n read Data prepare fail! : \(errorMessage)")
        }
        sqlite3_finalize(statement)
        return depts
    }
    
    func asklecture(dept: String, type: String) -> [Lecture] {
        //강의 조회하는 함수
        var lectures = [Lecture]()
        var query = "select * from lecture where d_code = \(dept);"
        if dept.contains("N") {
            let dabu = dept.components(separatedBy: "N")
            query = "select * from lecture where d_code = \(dabu[0]) or d_code = \(dabu[1]);"
        }
        if type.isEmpty == false {
            query.append(" and type = \(type)")
        }
        
        //db 구조: 테이블 2개(dept, lecture)
        //컬럼: dept(d_name text, d_code text)
        //  lecture(type text, l_number text, l_name text, credit integer, d_code text, time text, prof text, untact text, note text, section text)
        var statement : OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let type = String(cString: sqlite3_column_text(statement, 0))
                let l_number = String(cString: sqlite3_column_text(statement, 1))
                let l_name = String(cString: sqlite3_column_text(statement, 2))
                let d_code = String(cString: sqlite3_column_text(statement, 3))
                let prof = String(cString: sqlite3_column_text(statement, 4))
                let section = String(cString: sqlite3_column_text(statement, 5))
                lectures.append(Lecture(type: type, number: l_number, title: l_name, credit: credit, dept: d_code, time: time, prof: prof, untact: untact, note: note, section: ""))
                //전공 강의는 영역 몰라도 됨
                //print("readData result : \(name) \(code)")//
            }
        }
        else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("\n read Data prepare fail! : \(errorMessage)")
        }
        sqlite3_finalize(statement)
        return lectures     //배열 반환하기: func functionName() -> Lecture {}
    }
    
    func askLecInfo(d_code: String) -> [Lecture] {
        
    }
}
