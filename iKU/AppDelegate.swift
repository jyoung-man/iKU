//
//  AppDelegate.swift
//  iKU
//
//  Created by 박재영 on 2021/02/03.
//

import UIKit
import Siren

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var modal_height: CGFloat?
    var selected_lec: String?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Thread.sleep(forTimeInterval: 1.5)
        window?.makeKeyAndVisible()
        defaultExampleUsingCompletionHandler()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func defaultExampleUsingCompletionHandler() {
        let siren = Siren.shared
        siren.rulesManager = RulesManager(majorUpdateRules: Rules(promptFrequency: .immediately, forAlertType: .force), minorUpdateRules: Rules(promptFrequency: .immediately, forAlertType: .force), patchUpdateRules: .critical, revisionUpdateRules: Rules(promptFrequency: .daily, forAlertType: .option))
        
        siren.apiManager = APIManager(country: .korea)
        siren.presentationManager = PresentationManager(forceLanguageLocalization: .korean)
        siren.wail(performCheck: .onDemand) { results in
            switch results {
            case .success(let updateResults):
                print("AlertAction ", updateResults.alertAction)
                print("Localization ", updateResults.localization)
                print("Model ", updateResults.model)
                print("UpdateType ", updateResults.updateType)
            
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

