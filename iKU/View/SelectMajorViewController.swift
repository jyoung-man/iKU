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
    
    let ud = UserDefaults.standard
    let ad = UIApplication.shared.delegate as? AppDelegate

    let majorDropDown = DropDown()
    let firstSubmajorDropDown = DropDown()
    let secondSubmajorDropDown = DropDown()
    
    var depts = [Department]()
    var majorOnly = [String]()
    
//    let menu: DropDown = {
//        var depts = DBHelper().askDept()
//        var mymajor = [Department(d_name: "교직", d_code: "B04047")]
//        mymajor += depts
//        let menu = DropDown()
//        for m in mymajor {
//            menu.dataSource.append(m.d_name)
//        }
//        return menu
//    }()
//
    
    override func viewDidLoad() {
        super.viewDidLoad()
        depts = DBHelper().askDept()
        //교직 넣어야됨
        for d in depts {
            majorOnly.append(d.d_name)
        }
        setDropDown(dropdown: majorDropDown, button: myMajor)
        setDropDown(dropdown: firstSubmajorDropDown, button: firstSubmajor)
        setDropDown(dropdown: secondSubmajorDropDown, button: secondSubmajor)
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
    
    @IBAction func confirm(_ sender: UIButton) {
        ud.set(depts[majorDropDown.indexForSelectedRow ?? 0].getCode(), forKey: "department")
        ud.set(majorOnly[majorDropDown.indexForSelectedRow ?? 0], forKey: "mj_info")
        
        ud.set(depts[firstSubmajorDropDown.indexForSelectedRow ?? 0].getCode(), forKey: "double_major")
        ud.set(majorOnly[firstSubmajorDropDown.indexForSelectedRow ?? 0], forKey: "dm_info")
        
        ud.set(depts[secondSubmajorDropDown.indexForSelectedRow ?? 0].getCode(), forKey: "sub_major")
        ud.set(majorOnly[secondSubmajorDropDown.indexForSelectedRow ?? 0], forKey: "sm_info")
        
    }
    
}
