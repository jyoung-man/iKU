//
//  SelectGradeViewController.swift
//  iKU
//
//  Created by 박재영 on 2021/08/08.
//

import UIKit

class SelectGradeViewController: UIViewController {
    let ud = UserDefaults.standard

    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var oneKU: UIButton!
    @IBOutlet weak var twoKU: UIButton!
    @IBOutlet weak var threeKU: UIButton!
    @IBOutlet weak var fourKU: UIButton!
    @IBOutlet weak var first: UILabel!
    @IBOutlet weak var second: UILabel!
    @IBOutlet weak var third: UILabel!
    @IBOutlet weak var fourth: UILabel!
    @IBOutlet weak var backgroundView1: UIView!
    @IBOutlet weak var backgroundView2: UIView!
    @IBOutlet weak var backgroundView3: UIView!
    @IBOutlet weak var backgroundView4: UIView!
    
    @IBAction func iamFirst(_ sender: Any) {
        ud.set("1", forKey: "grade")
        first.textColor = UIColor(white: 0, alpha: 1)
        setLabelColorDark(label: second)
        setLabelColorDark(label: third)
        setLabelColorDark(label: fourth)
        setBackgroundViewDark()
        backgroundView1.backgroundColor = .systemBackground

    }
    @IBAction func iamSecond(_ sender: Any) {
        ud.set("2", forKey: "grade")
        second.textColor = UIColor(white: 0, alpha: 1)
        setLabelColorDark(label: first)
        setLabelColorDark(label: third)
        setLabelColorDark(label: fourth)
        setBackgroundViewDark()
        backgroundView2.backgroundColor = .systemBackground

    }
    @IBAction func iamThird(_ sender: Any) {
        ud.set("3", forKey: "grade")
        third.textColor = UIColor(white: 0, alpha: 1)
        setLabelColorDark(label: first)
        setLabelColorDark(label: second)
        setLabelColorDark(label: fourth)
        setBackgroundViewDark()
        backgroundView3.backgroundColor = .systemBackground

    }
    @IBAction func iamFourth(_ sender: Any) {
        ud.set("4", forKey: "grade")
        fourth.textColor = UIColor(white: 0, alpha: 1)
        setLabelColorDark(label: first)
        setLabelColorDark(label: second)
        setLabelColorDark(label: third)
        setBackgroundViewDark()
        backgroundView4.backgroundColor = .systemBackground

    }
    
    func setLabelColorDark(label: UILabel) {
        label.textColor = UIColor(red: 112/255, green: 112/255, blue: 112/255, alpha: 1.0)
    }
    
    func setBackgroundViewDark() {
        backgroundView1.backgroundColor = .clear
        backgroundView2.backgroundColor = .clear
        backgroundView3.backgroundColor = .clear
        backgroundView4.backgroundColor = .clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView1.layer.cornerRadius = 20
        backgroundView2.layer.cornerRadius = 20
        backgroundView3.layer.cornerRadius = 20
        backgroundView4.layer.cornerRadius = 20
        setLabelColorDark(label: second)
        setLabelColorDark(label: third)
        setLabelColorDark(label: fourth)
        setBackgroundViewDark()
        backgroundView1.backgroundColor = .systemBackground
        first.textColor = UIColor(white: 0, alpha: 1)
        confirmButton.layer.cornerRadius = 20
    }
}
