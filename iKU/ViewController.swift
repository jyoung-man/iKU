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
    
    var depts = [Department]()
    let ad = UIApplication.shared.delegate as? AppDelegate
    @IBAction func inputGrade(_ sender: UITextField) {
        if sender.text == "1" || sender.text == "2" || sender.text == "3" || sender.text == "4" {
            self.button.isEnabled = true
        }
        else if sender.text == "5"{
                print("대충 5학년이 어딨냐는 내용")
            self.button.isEnabled = false

        }
        else {
            print("닷 내용")
            self.button.isEnabled = false

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        depts = DBHelper().askDept()
        picker_major.dataSource = self
        picker_major.delegate = self
        
        picker_da.dataSource = self
        picker_da.delegate = self
            
        picker_bu.dataSource = self
        picker_bu.delegate = self
        self.button.isEnabled = false
    }
    @IBAction func sender(_ sender: UIButton) {
        ad?.department = depts[self.picker_major.selectedRow(inComponent: 0)].getCode()
        ad?.double_major = depts[self.picker_da.selectedRow(inComponent: 0)].getCode()
        ad?.sub_major = depts[self.picker_bu.selectedRow(inComponent: 0)].getCode()
        ad?.grade = text_grade.text

        let dept: String? = ad?.department
        let double: String? = ad?.double_major
        let sub: String? = ad?.sub_major
        let grade: String? = ad?.grade


        print(dept!)
        print(double!)
        print(sub!)
        print(grade!)
    }
}

extension ViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return depts.count
    }
    
    
}

extension ViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return depts[row].d_name
    }
    
}
