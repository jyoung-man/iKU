//
//  SelectMajorViewController.swift
//  iKU
//
//  Created by 박재영 on 2021/08/05.
//

import UIKit
import DropDown

class SelectMajorViewController: UIViewController {

    @IBOutlet weak var myMajor: UIButton!
    @IBOutlet weak var firstSubmajor: UIButton!
    @IBOutlet weak var secondSubmajor: UIButton!
    @IBOutlet weak var confirm: UIButton!
    @IBOutlet weak var kuImg: UIImageView!
    @IBOutlet weak var backgroundView: UIView!
    
    let ud = UserDefaults.standard
    let ad = UIApplication.shared.delegate as? AppDelegate

    let majorDropDown = DropDown()
    let firstSubmajorDropDown = DropDown()
    let secondSubmajorDropDown = DropDown()
    
    var depts = [Department]()
    var majorOnly = [String]()
    var gradeValue: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        gradeValue = ud.string(forKey: "grade") ?? "1"
        gradeValue = gradeValue! + "학년"
        kuImg.image = UIImage(named: gradeValue!)
        depts = DBHelper().askDept()
        depts.append(Department(d_name: "없음 \t", d_code: "999999"))
        //교직 넣어야됨
        for d in depts {
            majorOnly.append(d.d_name)
        }
        setDropDown(dropdown: majorDropDown, button: myMajor)
        setDropDown(dropdown: firstSubmajorDropDown, button: firstSubmajor)
        setDropDown(dropdown: secondSubmajorDropDown, button: secondSubmajor)
        self.confirm.layer.cornerRadius = 20
        self.backgroundView.layer.cornerRadius = 20
        checkYourMajor()
        if (ud.string(forKey: "department") != nil) {
            self.performSegue(withIdentifier: "mainView", sender: self)
        }
    }
    
    @IBAction func confirmAction(_ sender: Any) {
        ud.set(depts[majorDropDown.indexForSelectedRow ?? 0].getCode(), forKey: "department")
        ud.set(majorOnly[majorDropDown.indexForSelectedRow ?? 0], forKey: "mj_info")

        init_data()
    }
    
    func init_data() {
        ud.set(depts[firstSubmajorDropDown.indexForSelectedRow ?? depts.count-1].getCode(), forKey: "double_major")
        ud.set(majorOnly[firstSubmajorDropDown.indexForSelectedRow ?? depts.count-1], forKey: "dm_info")
        
        ud.set(depts[secondSubmajorDropDown.indexForSelectedRow ?? depts.count-1].getCode(), forKey: "sub_major")
        ud.set(majorOnly[secondSubmajorDropDown.indexForSelectedRow ?? depts.count-1], forKey: "sm_info")
    }
    
    func checkYourMajor() {
        let d1 = ud.string(forKey: "department") ?? "**"
        let d2 = ud.string(forKey: "double_major") ?? "**"
        let d3 = ud.string(forKey: "sub_major") ?? "**"
        
        if !DBHelper().checkDept(dept: d1) {
            ud.removeObject(forKey: "department")
            ud.removeObject(forKey: "mj_info")
        }
        if !DBHelper().checkDept(dept: d2) {
            ud.set(depts[firstSubmajorDropDown.indexForSelectedRow ?? depts.count-1].getCode(), forKey: "double_major")
            ud.set(majorOnly[firstSubmajorDropDown.indexForSelectedRow ?? depts.count-1], forKey: "dm_info")
        }
        
        if !DBHelper().checkDept(dept: d3) {
            ud.set(depts[secondSubmajorDropDown.indexForSelectedRow ?? depts.count-1].getCode(), forKey: "sub_major")
            ud.set(majorOnly[secondSubmajorDropDown.indexForSelectedRow ?? depts.count-1], forKey: "sm_info")
        }
    }
    
    
    func setDropDown(dropdown: DropDown, button: UIButton) {
        dropdown.dataSource = self.majorOnly
        dropdown.anchorView = button
        dropdown.bottomOffset = CGPoint(x: 0, y: (dropdown.anchorView?.plainView.bounds.height)!)
        dropdown.cornerRadius = 15
        button.titleEdgeInsets = UIEdgeInsets(top: CGFloat(0), left: CGFloat(20.0), bottom: CGFloat(0), right: CGFloat(0))
        button.layer.cornerRadius = 20

        button.titleLabel?.text = dropdown.selectedItem
    }
    
    @IBAction func showDropDownA(_ sender: UIButton) {
        majorDropDown.show()
        majorDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            myMajor.setTitle(item, for: .normal)
        }
    }
    @IBAction func showDropDownB(_ sender: UIButton) {
        firstSubmajorDropDown.show()
        firstSubmajorDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            firstSubmajor.setTitle(item, for: .normal)
        }
    }
    @IBAction func showDropDownC(_ sender: UIButton) {
        secondSubmajorDropDown.show()
        secondSubmajorDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            secondSubmajor.setTitle(item, for: .normal)
        }
    }
}
