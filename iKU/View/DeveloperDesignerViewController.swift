//
//  DeveloperDesignerViewController.swift
//  iKU
//
//  Created by 박재영 on 2021/08/14.
//

import UIKit

class DeveloperDesignerViewController: UIViewController {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var developerView: UIView!
    @IBOutlet weak var designerView: UIView!
    @IBOutlet weak var developerShadow: UIView!
    @IBOutlet weak var designerShadow: UIView!
    
    @IBOutlet weak var contactDeveloper: UIView!
    @IBOutlet weak var contactDesigner: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.layer.cornerRadius = backgroundView.frame.height / 15
        
        contactDeveloper.layer.cornerRadius = 10
        contactDeveloper.layer.borderWidth = 0.5
        contactDeveloper.layer.borderColor = CGColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1)

        contactDesigner.layer.cornerRadius = 10
        contactDesigner.layer.borderWidth = 0.5
        contactDesigner.layer.borderColor = CGColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1)
        
        setShadow(myView: developerView, shadowView: developerShadow)
        setShadow(myView: designerView, shadowView: designerShadow)
    }
    

    func setShadow(myView: UIView, shadowView: UIView) {
        myView.layer.borderWidth = 1
        myView.layer.borderColor = CGColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1)
        myView.layer.cornerRadius = myView.frame.height / 5
        myView.layer.masksToBounds = true
        shadowView.layer.cornerRadius = myView.frame.height / 5
        shadowView.layer.masksToBounds = false
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 10)
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.03
        shadowView.layer.shadowRadius = myView.frame.height / 3
        shadowView.layer.shadowPath = UIBezierPath(roundedRect: myView.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 2, height: 1)).cgPath
        shadowView.layer.shouldRasterize = true
        shadowView.layer.rasterizationScale = UIScreen.main.scale
    }

}
