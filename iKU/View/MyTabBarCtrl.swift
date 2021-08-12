//
//  MyTabBarCtrl.swift
//  iKU
//
//  Created by 박재영 on 2021/08/07.
//

import UIKit
import SwiftIcons
class MyTabBarCtrl: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.selectedIndex = 1
            
   }
}
