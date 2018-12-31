//
//  CollectionViewController.swift
//  XTVT
//
//  Created by Admin on 12/26/18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit
import SideMenu
import CoreLocation

class CollectionViewController: UIViewController, UICollectionViewDelegate,  UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate{
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var labelTitle: UILabel!
    
    var type:Int = Constants.catNumAll
    var mArrayList:NSMutableArray?
    var page:Int = 1
    var totalCount:Int = -1
    var sv:UIView! = nil
    var currentLocation: CLLocation!
    var locationManager: CLLocationManager!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        self.mArrayList = NSMutableArray()
        self.sv = UtilityFunc().displaySpinner(onView: self.view)
        setTitle()
        loadData()
    }
    
    func setTitle() {
        if type == Constants.catNumAll {
            self.labelTitle.text = "All Places"
        } else if type == Constants.catNumBeach {
            self.labelTitle.text = "Beach & Water Activities"
        } else if type == Constants.catNumFeatured {
            self.labelTitle.text = "Featured Activities"
        } else if type == Constants.catNumTopTourist {
            self.labelTitle.text = "Top Tourist Activities"
        } else if type == Constants.catNumFood {
            self.labelTitle.text = "Local Cuisines"
        } else if type == Constants.catNumClimbing {
            self.labelTitle.text = "Climbing Activities"
        } else if type == Constants.catNumCaving {
            self.labelTitle.text = "Caving Activities"
        } else if type == Constants.catNumCultural {
            self.labelTitle.text = "Cultural Activities"
        } else if type == Constants.catNumPark {
            self.labelTitle.text = "Parks & Trails"
        } else if type == Constants.catNumOthers {
            self.labelTitle.text = "Other Activities"
        }
    }
    
    func loadData() {
        fetchData { (dict, error) in
            let status:String = dict?["status"] as! String
            if status == "success" {
                self.totalCount = dict?["count_total"] as! Int
                let placeInfos = dict?["places"] as! NSArray
                
                for i in 0 ..< placeInfos.count {
                    let info = placeInfos.object(at: i) as! [String:AnyObject]
                    var item:Dictionary = [String: Any]()
                    item["name"] = info["name"] as? String
                    item["image"] = info["image"] as? String
                    item["place_id"] = info["place_id"] as? Int
                    item["lat"] = info["lat"] as? Double
                    item["lng"] = info["lng"] as? Double
                    
                    
                    if self.type != Constants.catNumAll {
                        
                        if self.type == Constants.catNumFavorite {
                            let defaults = UserDefaults.standard
                            let array = defaults.array(forKey: "SavedIntArray")  as? [Int] ?? [Int]()
                            
                            if array.contains(item["place_id"] as! Int) {
                                self.mArrayList?.add(item)
                            }
                        } else {
                            var isFilter:Bool = false

                            let categoriesInfo = info["categories"] as! NSArray
                            for i in 0 ..< categoriesInfo.count {
                                let cateInfo = categoriesInfo.object(at: i) as! [String:AnyObject]
                                let catId = cateInfo["cat_id"] as? Int
                                
                                if catId == self.type {
                                    isFilter = true
                                    break
                                }
                            }
                            
                            if isFilter {
                                self.mArrayList?.add(item)
                            }
                        }
                    } else {
                        self.mArrayList?.add(item)
                    }
                }
               
                if self.totalCount > 0 && self.page * Constants.LIMIT_LOADMORE < self.totalCount {
                    self.page += 1
                    self.loadData()
                } else {
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                        UtilityFunc().removeSpinner(spinner: self.sv)
                    }
                }
            }
        }
    }
    

    func fetchData(completion: @escaping ([String:Any]?, Error?) -> Void) {
        let url = URL(string: Constants.WEB_URL + Constants.getPlacesByPage + "?page=\(page)&count=\(Constants.LIMIT_LOADMORE)&draft=\(page * Constants.LIMIT_LOADMORE)")!
        
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
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat =  15
        
        let collectionViewSize = collectionView.frame.size.width - padding
        
        return CGSize(width: collectionViewSize/2, height: collectionViewSize/2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    //--------------------------------------------------------------------------------
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5;
    }
    
    //--------------------------------------------------------------------------------
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1     //return number of sections in collection view
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.mArrayList?.count)!

    //return number of rows in section
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath as IndexPath) as! CollectionViewCell
        configureCell(cell: cell, forItemAtIndexPath: indexPath as NSIndexPath)
        let item = self.mArrayList?.object(at: indexPath.row) as! NSDictionary
        let pathName = item.object(forKey: "image") as! String
        
        getData(from: URL(string: Constants.WEB_URL + Constants.getImagePath + pathName)!) { data, response, error in
         guard let data = data, error == nil else { return }
             DispatchQueue.main.async() {
                cell.imageView.image = UIImage(data: data)
                
             }
         }
        
        cell.labelTitle.text = item.object(forKey: "name") as? String

        
        let latitude = item.object(forKey: "lat") as! Double
        let longitude = item.object(forKey: "lat") as! Double
        
        let coordinate0 = CLLocation(latitude: latitude, longitude: longitude)
        let distanceInMeters = coordinate0.myDistance(coordinate: currentLocation)
        cell.distanceLabel.text = distanceInMeters
        
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_:))))

        return cell      //return your cell
    }
    
    func configureCell(cell: UICollectionViewCell, forItemAtIndexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.black
        //Customise your cell
        
    }
    
    private func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: IndexPath) -> UICollectionReusableView {
        let view =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CollectionViewCell", for: indexPath as IndexPath) as UICollectionReusableView
        return view
    }
    
    
    @objc func tap(_ sender: UITapGestureRecognizer) {
        
        let location = sender.location(in: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: location)
        
        if let index = indexPath {
            if let viewController = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
                if let navigator = navigationController {
                    let item = self.mArrayList?.object(at: index.row) as! NSDictionary
                    viewController.place_id = item.object(forKey: "place_id") as! Int
                    navigator.pushViewController(viewController, animated: true)
                }
            }
        }
    }
    
    //MARK: UICollectionViewDelegate
    private func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // When user selects the cell

        
    }
    
    private func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: IndexPath) {
        // When user deselects the cell
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
    
    @IBAction func clickRefresh(_ sender: Any) {
        self.sv = UtilityFunc().displaySpinner(onView: self.view)
        loadData()
    }
    
    @IBAction func searchButtonClick(_ sender: Any) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController {
            if let navigator = navigationController {
                viewController.collectionVC = self
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    @IBAction func clickSlideMenu(_ sender: Any) {
        SideMenuManager.default.menuLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? UISideMenuNavigationController
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        defer { currentLocation = locations.last }
        
        if currentLocation == nil {
            // Zoom to user location
            if let userLocation = locations.last {
                self.currentLocation = userLocation
            }
        }
    }
}

extension CLLocation {
    
    func myDistance(coordinate: CLLocation)->String{
        
        let distanceInMeters = self.distance(from: coordinate)
        
        if distanceInMeters < 1000 {
            return distanceInMeters.description + " M"
        }else{
            let distanceInKilometer = distanceInMeters /  1000
            return String(format:"%.1f", distanceInKilometer) + " KM"
        }
        
    }
    
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
