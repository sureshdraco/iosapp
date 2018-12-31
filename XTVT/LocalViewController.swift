//
//  LocalViewController.swift
//  XTVT
//
//  Created by Admin on 12/28/18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit
import SideMenu

class LocalViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func clickSlideMenu(_ sender: Any) {
        SideMenuManager.default.menuLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? UISideMenuNavigationController
        SideMenuManager.default.menuAllowPushOfSameClassTwice = true
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }
    
    @IBAction func clickFeatured(_ sender: Any) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "CollectionViewController") as? CollectionViewController {
            if let navigator = navigationController {
                viewController.type = Constants.catNumFeatured
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    @IBAction func clickTop(_ sender: Any) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "CollectionViewController") as? CollectionViewController {
            if let navigator = navigationController {
                viewController.type = Constants.catNumTopTourist
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    @IBAction func clickLocal(_ sender: Any) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "CollectionViewController") as? CollectionViewController {
            if let navigator = navigationController {
                viewController.type = Constants.catNumFood
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    @IBAction func clickBeach(_ sender: Any) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "CollectionViewController") as? CollectionViewController {
            if let navigator = navigationController {
                viewController.type = Constants.catNumBeach
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    @IBAction func clickClimb(_ sender: Any) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "CollectionViewController") as? CollectionViewController {
            if let navigator = navigationController {
                viewController.type = Constants.catNumClimbing
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    @IBAction func clickCaving(_ sender: Any) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "CollectionViewController") as? CollectionViewController {
            if let navigator = navigationController {
                viewController.type = Constants.catNumCaving
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    @IBAction func clickCulture(_ sender: Any) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "CollectionViewController") as? CollectionViewController {
            if let navigator = navigationController {
                viewController.type = Constants.catNumCultural
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    @IBAction func clickParking(_ sender: Any) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "CollectionViewController") as? CollectionViewController {
            if let navigator = navigationController {
                viewController.type = Constants.catNumPark
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    @IBAction func clickOther(_ sender: Any) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "CollectionViewController") as? CollectionViewController {
            if let navigator = navigationController {
                viewController.type = Constants.catNumOthers
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func rateApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/" + appId) else {
            completion(false)
            return
        }
        guard #available(iOS 10, *) else {
            completion(UIApplication.shared.openURL(url))
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }
    

    @IBAction func clickMore(_ sender: Any) {
        let myActionSheet = UIAlertController(title: "More Options", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        
        //edit action button
        let settingAction = UIAlertAction(title: "Setting", style: UIAlertAction.Style.default) { (action) in
            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SettingViewController") as? SettingViewController {
                if let navigator = self.navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }
            }
        }
        
        //capture action button
        let rateAction = UIAlertAction(title: "Rate", style: UIAlertAction.Style.default) { (action) in
            self.rateApp(appId: Constants.APP_ID) { success in
                print("RateApp \(success)")
            }
        }
        
        //comment action button
        let aboutAction = UIAlertAction(title: "About", style: UIAlertAction.Style.default) { (action) in
            self.present(UtilityFunc().showAlertContrller(title: "About", message: "All XTVT to do in Malasia."), animated: true, completion: nil)
        }
        
        // cancel action button
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (action) in
            print("Cancel action button tapped")
        }
        
        // add action buttons to action sheet
        myActionSheet.addAction(settingAction)
        myActionSheet.addAction(rateAction)
        myActionSheet.addAction(aboutAction)
        myActionSheet.addAction(cancelAction)
        
        // present the action sheet
        self.present(myActionSheet, animated: true, completion: nil)
    }
}
