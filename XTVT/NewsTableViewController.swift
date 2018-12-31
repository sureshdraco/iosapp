//
//  NewsTableViewController.swift
//  XTVT
//
//  Created by Admin on 12/28/18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit
import SideMenu

class NewsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var mArrayList:NSMutableArray?
    var page:Int = 1
    var totalCount:Int = -1
    var sv:UIView! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.mArrayList = NSMutableArray()
        self.sv = UtilityFunc().displaySpinner(onView: self.view)
        loadData()
    }

    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    
    func loadData() {
        fetchData { (dict, error) in
            let status:String = dict?["status"] as! String
            if status == "success" {
                self.totalCount = dict?["count_total"] as! Int
                let newsInfos = dict?["news_infos"] as! NSArray
                
                for i in 0 ..< newsInfos.count {
                    let info = newsInfos.object(at: i) as! [String:AnyObject]
                    var item:Dictionary = [String: Any]()
                    item["title"] = info["title"] as? String
                    item["image"] = info["image"] as? String
                    item["brief_content"] = info["brief_content"] as? String
                    item["full_content"] = info["full_content"] as? String
                    item["last_update"] = info["last_update"] as? Int

                    self.mArrayList?.add(item)
                }
                
                if self.totalCount > 0 && self.page * Constants.LIMIT_LOADMORE < self.totalCount {
                    self.page += 1
                    self.loadData()
                } else {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        UtilityFunc().removeSpinner(spinner: self.sv)
                    }
                }
            }
        }
    }
    
    
    func fetchData(completion: @escaping ([String:Any]?, Error?) -> Void) {
        let url = URL(string: Constants.WEB_URL + Constants.getNewsInfoByPage + "?page=\(page)&count=\(Constants.LIMIT_LOADMORE)")!
        
        print(url)
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            do {
                if let array = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any]{
                    completion(array, nil)
                }
            } catch {
                print(error)
                completion(nil, error)
            }
        }
        task.resume()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 270.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        
        return (self.mArrayList?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsItemTableViewCell", for: indexPath) as! NewsItemTableViewCell
        
        let item = self.mArrayList?.object(at: indexPath.row) as! NSDictionary
        
        let pathName = item.object(forKey: "image") as! String
        let fullPath = Constants.WEB_URL + Constants.getNewsImagePath + pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        getData(from: URL(string: fullPath)!) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                cell.imagePicture.image = UIImage(data: data)
                
            }
        }
        
        cell.titleLabel.text = item.object(forKey: "title") as! String?
        cell.detailLabel.text = item.object(forKey: "brief_content") as! String?
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "NewsDetailViewController") as? NewsDetailViewController {
            if let navigator = navigationController {
                let item = self.mArrayList?.object(at: indexPath.row) as! NSDictionary
                viewController.detailInfo = item
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    @IBAction func clickSideMenu(_ sender: Any) {
        SideMenuManager.default.menuLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? UISideMenuNavigationController
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }
    
    @IBAction func clickRefresh(_ sender: Any) {
        self.sv = UtilityFunc().displaySpinner(onView: self.view)
        loadData()
    }
    
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
