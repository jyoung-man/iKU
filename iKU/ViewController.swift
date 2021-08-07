//
//  ViewController.swift
//  iKU
//
//  Created by 박재영 on 2021/02/03.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var picker_major: UIPickerView!
    @IBOutlet weak var picker_da: UIPickerView!
    @IBOutlet weak var picker_bu: UIPickerView!
    @IBOutlet weak var text_grade: UITextField!
    @IBOutlet weak var button: UIButton!
    
    let ud = UserDefaults.standard

    var depts = [Department]()
    var mymajor: [Department] = [Department(d_name: "원전공", d_code: "onemajor")]
    var doublemajor: [Department] = [Department(d_name: "다/부전공 1", d_code: "dabu1"), Department(d_name: "없음", d_code: "nothing"), Department(d_name: "교직", d_code: "B04047")]
    var submajor: [Department] = [Department(d_name: "다/부전공 2", d_code: "dabu1"), Department(d_name: "없음", d_code: "nothing"), Department(d_name: "교직", d_code: "B04047")]
    
    @IBAction func inputGrade(_ sender: UITextField) {
        if sender.text == "1" || sender.text == "2" || sender.text == "3" || sender.text == "4" {
            self.button.isEnabled = true
        }
        else {
            self.button.isEnabled = false

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        depts = DBHelper().askDept()
        mymajor += depts
        doublemajor += depts
        submajor += depts
        
        picker_major.dataSource = self
        picker_major.delegate = self
        picker_da.dataSource = self
        picker_da.delegate = self
            
        picker_bu.dataSource = self
        picker_bu.delegate = self
        self.button.isEnabled = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
        print("Tap is working")
    }
    
    
    @IBAction func sender(_ sender: UIButton) {
        ud.set(self.mymajor[self.picker_major.selectedRow(inComponent: 0)].getCode(), forKey: "department")
        ud.set(self.mymajor[self.picker_major.selectedRow(inComponent: 0)].getName(), forKey: "mj_info")
        ud.set(self.doublemajor[self.picker_da.selectedRow(inComponent: 0)].getCode(), forKey: "double_major")
        ud.set(self.doublemajor[self.picker_da.selectedRow(inComponent: 0)].getName(), forKey: "dm_info")
        ud.set(self.submajor[self.picker_bu.selectedRow(inComponent: 0)].getCode(), forKey: "sub_major")
        ud.set(self.submajor[self.picker_bu.selectedRow(inComponent: 0)].getName(), forKey: "sm_info")
        ud.set(self.text_grade.text, forKey: "grade")

        let alert = UIAlertController(title: "알림", message: "설정이 저장되었습니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
}

extension ViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == picker_major {
            return mymajor.count
        }
        else if pickerView == picker_da {
            return doublemajor.count
        }
        else if pickerView == picker_bu {
            return submajor.count
        }
        else {
            return depts.count
        }
    }
}

extension ViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == picker_major {
            return mymajor[row].d_name
        }
        else if pickerView == picker_da {
            return doublemajor[row].d_name
        }
        else if pickerView == picker_bu {
            return submajor[row].d_name
        }
        else {
            return depts[row].d_name
        }
        
    }
    
}
