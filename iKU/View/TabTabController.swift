//
//  TabTabController.swift
//  iKU
//
//  Created by 박재영 on 2021/02/03.
//

import UIKit

class TabTabController: UITabBarController {
    let ud = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        let customTabBar = CustomTabBar()
               self.setValue(customTabBar, forKeyPath: "tabBar")

    }
}
