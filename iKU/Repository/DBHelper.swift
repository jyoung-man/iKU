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
    var path : String = "ikuV1.sqlite"
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
    
    func askLecture(dept: String, type: String) -> [Lecture] {
        //강의 조회하는 함수
        var lectures = [Lecture]()
        var query = "select * from lecture where d_code = '\(dept)' and type = '\(type)';"
        if dept.contains("&") {
            let dabu = dept.components(separatedBy: "&")
            query = "select * from lecture where d_code = '\(dabu[0])' or d_code = '\(dabu[1])' and type = '\(type)';"
        }
        if dept == "B0404P" { //교양과목 조회하는 경우
            if type.contains("&") {
                let sec = type.components(separatedBy: "&")

                if sec.count > 2 {
                    query = "select * from lecture where section = '\(sec[0])' or section = '\(sec[1])' or section = '\(sec[2])' ;"                    
                }
                else {
                    query = "select * from lecture where section = '\(sec[0])' or section = '\(sec[1])' ;"
                }
                
            }
            else {
                query = "select * from lecture where section = '\(type)' ;"
            }
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
                lectures.append(Lecture(type: type, number: l_number, title: l_name, dept: d_code, prof: prof, section: section))
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
    
    func askLecInfo(l_number: String) -> [String] {
        let query = "select * from lecture natural join lec_info where l_number = '\(l_number)';"
        var statement : OpaquePointer? = nil
        var lecInfo = [String]()
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let type = String(cString: sqlite3_column_text(statement, 0))
                let l_number = String(cString: sqlite3_column_text(statement, 1))
                let l_name = String(cString: sqlite3_column_text(statement, 2))
                let section = String(cString: sqlite3_column_text(statement, 5))
                let credit = sqlite3_column_int(statement, 6)
                let time = String(cString: sqlite3_column_text(statement, 7))
                let classroom = String(cString: sqlite3_column_text(statement, 8))
                let untact = String(cString: sqlite3_column_text(statement, 9))
                let isuntact = isUntact(untact: untact)
                let note = String(cString: sqlite3_column_text(statement, 10))
                //순서: 이름 번호 이수구분 학점/ 장소 대면비대면 시간/ 담당교수 메일 연구실
                
                lecInfo.append(l_name)
                lecInfo.append(l_number)
                lecInfo.append("\(type) \(section)")
                lecInfo.append(String(credit)+"학점")
                lecInfo.append(time)
                lecInfo.append(classroom)
                lecInfo.append(isuntact)
                lecInfo.append(note)
                break
            }
        }
        else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("\n read Data prepare fail! : \(errorMessage)")
        }
        sqlite3_finalize(statement)
        return lecInfo
    }
    
    func askProf(l_number: String) -> [String] {
        let query = "select * from professor where prof in (select prof from lecture where l_number = '\(l_number)' );"
        var statement : OpaquePointer? = nil
        var prof_contact = [String]()
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let prof = String(cString: sqlite3_column_text(statement, 0))
                let lab = String(cString: sqlite3_column_text(statement, 1))
                let contact = String(cString: sqlite3_column_text(statement, 2))
                prof_contact.append(prof)
                prof_contact.append(contact)
                prof_contact.append(lab)
                break
            }
        }
        else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("\n read Data prepare fail! : \(errorMessage)")
        }
        sqlite3_finalize(statement)
        
        return prof_contact
    }
    
    func askTypeOrSection(dept: String, target: String) -> [String] {
        let query = "select \(target) from lecture where d_code = '\(dept)';"
        var statement : OpaquePointer? = nil
        var tos = [String]()
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let type = String(cString: sqlite3_column_text(statement, 0))
                tos.append(type)
                break
            }
        }
        else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("\n read Data prepare fail! : \(errorMessage)")
        }
        sqlite3_finalize(statement)
        return tos
    }
    
    func isUntact(untact: String) -> String {
        var rate: [String?]
        let info = ["녹화: ", "실시간: ", "대면: "]
        var result: String = ""
        var i: Int = 0
        if untact.contains(":") {
            rate = untact.components(separatedBy: ":")
            for r in rate {
                if r == "0" {
                    continue
                }
                else {
                    result.append("\(info[i])\(r!) ")
                }
                i+=1
            }
            return result
        }
        else {
            return untact
        }
    }
}
