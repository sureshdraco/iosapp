//
//  DetailViewController.swift
//  XTVT
//
//  Created by Admin on 12/27/18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UIViewController, UITextViewDelegate, UICollectionViewDelegate,  UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var labelAddress: UILabel!
    @IBOutlet weak var labelPhone: UILabel!
    
    @IBOutlet weak var labelWeb: UILabel!
    
    @IBOutlet weak var labelDescription: UITextView!
    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var labelTitle: UILabel!
    
    @IBOutlet weak var heightDescriptionView: NSLayoutConstraint!
    @IBOutlet weak var heightParentView: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var favoriteButton: UIButton!
    var mArrayList:NSMutableArray?
    var place_id:Int = 0
    var sv:UIView! = nil
    var coordinate = CLLocationCoordinate2D()
    var textTitleString:String = ""
    
    var isOn:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.sv = UtilityFunc().displaySpinner(onView: self.view)
        
        let defaults = UserDefaults.standard
        let array = defaults.array(forKey: "SavedIntArray")  as? [Int] ?? [Int]()
        
        if array.contains(place_id) {
            favoriteButton.setImage(UIImage(named: "btn_favorite_on.png"), for: UIControl.State.normal)
            self.isOn = true
        } else {
            favoriteButton.setImage(UIImage(named: "btn_favorite_off.png"), for: UIControl.State.normal)
            self.isOn = false
        }
        
        
        self.mArrayList = NSMutableArray()

        // Do any additional setup after loading the view.
        fetchData { (dict, error) in
            let placeInfo = dict?["place"] as! [String:AnyObject]
            let pathName = placeInfo["image"] as! String
            
            self.getData(from: URL(string: Constants.WEB_URL + Constants.getImagePath + pathName)!) { data, response, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async() {
                    self.imageView.image = UIImage(data: data)
                    
                }
            }
            
            let imagesInfo = placeInfo["images"] as! NSArray
            
            for i in 0 ..< imagesInfo.count {
                let info = imagesInfo.object(at: i) as! [String:AnyObject]
                var item:Dictionary = [String: Any]()
                item["image"] = info["name"] as? String
                self.mArrayList?.add(item)
                
            }
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.labelTitle.text = placeInfo["name"] as? String
                self.labelAddress.text = placeInfo["address"] as? String
                self.labelPhone.text = placeInfo["phone"] as? String
                self.labelWeb.text = placeInfo["website"] as? String
                
                if self.labelPhone.text?.count == 0 {
                    self.labelPhone.text = "No phone number listed"
                }
                
                if self.labelWeb.text?.count == 0 {
                    self.labelWeb.text = "No website listed"
                }
                
                self.textTitleString = (placeInfo["name"] as? String)!
                self.collectionView.reloadData()
                
                let htmlText = placeInfo["description"] as? String
                let encodedData = htmlText!.data(using: String.Encoding.utf8)!
                var attributedString: NSAttributedString
                
                
                let latitude = placeInfo["lat"] as? Double
                let longitude = placeInfo["lng"] as? Double
                
                let annotation = MKPointAnnotation()
                annotation.title = self.title
                self.coordinate.latitude = latitude!
                self.coordinate.longitude = longitude!
                annotation.coordinate = self.coordinate
                
                var region = MKCoordinateRegion()
                var span = MKCoordinateSpan()
                
                span.latitudeDelta = 0.05     // 0.0 is min value u van provide for zooming
                span.longitudeDelta = 0.05
                region.span=span;
                region.center = self.coordinate;     // to locate to the center
                self.map.addAnnotation(annotation)
                self.map.setRegion(region, animated: true)
                self.map.regionThatFits(region)
                
                do {
                    attributedString = try NSAttributedString(data: encodedData, options: [NSAttributedString.DocumentReadingOptionKey.documentType:NSAttributedString.DocumentType.html,NSAttributedString.DocumentReadingOptionKey.characterEncoding:NSNumber(value: String.Encoding.utf8.rawValue)], documentAttributes: nil)
                    self.labelDescription.attributedText = attributedString
                    
                    //change description size
                    let sizeToFitIn = CGSize(width: self.labelDescription.bounds.size.width, height:CGFloat(MAXFLOAT))
                    let newSize = self.labelDescription.sizeThatFits(sizeToFitIn)
                    self.heightDescriptionView.constant = self.heightDescriptionView.constant  - 52.0 + newSize.height
                    self.heightParentView.constant = self.heightParentView.constant - 52.0 + newSize.height
                } catch let error as NSError {
                    print(error.localizedDescription)
                } catch {
                    print("error")
                }
                
                UtilityFunc().removeSpinner(spinner: self.sv)
            }
        }
        

    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func fetchData(completion: @escaping ([String:Any]?, Error?) -> Void) {
        let url = URL(string: Constants.WEB_URL + Constants.getPlaceDetails + "?place_id=\(place_id)")!
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
    
    @IBAction func shareButtonClick(_ sender: Any) {
        let text = self.labelDescription.text
        let image = self.imageView.image
        let shareAll = [text as Any , image!]
        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func backButtonClick(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func navigateButtonClick(_ sender: Any) {
        let regionDistance:CLLocationDistance = 1000
        let regionSpan = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey:NSValue(mkCoordinateSpan: regionSpan.span)]
        
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = self.textTitleString
        mapItem.openInMaps(launchOptions: options)
    }
    
    @IBAction func mapViewButtonClick(_ sender: Any) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "MapViewController") as? MapViewController {
            if let navigator = navigationController {
                viewController.detailCV = self
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
    
    //MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat =  10
        
        let collectionViewSize = collectionView.frame.size.height - padding
        
        return CGSize(width: collectionViewSize, height: collectionViewSize)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath as IndexPath) as! ImageCollectionViewCell
        configureCell(cell: cell, forItemAtIndexPath: indexPath as NSIndexPath)
        let item = self.mArrayList?.object(at: indexPath.row) as! NSDictionary
        let pathName = item.object(forKey: "image") as! String
        
        let fullPath = Constants.WEB_URL + Constants.getImagePath + pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        getData(from: URL(string: fullPath)!) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                cell.imageView.image = UIImage(data: data)
                
            }
        }

        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_:))))
        
        return cell      //return your cell
    }
    
    func configureCell(cell: UICollectionViewCell, forItemAtIndexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.black
        //Customise your cell
        
    }
    
    private func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: IndexPath) -> UICollectionReusableView {
        let view =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ImageCollectionViewCell", for: indexPath as IndexPath) as UICollectionReusableView
        return view
    }
    
    
    @objc func tap(_ sender: UITapGestureRecognizer) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "ImageSlideViewController") as? ImageSlideViewController {
            if let navigator = navigationController {
                viewController.detailCV = self
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    //MARK: UICollectionViewDelegate
    private func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // When user selects the cell
        
        
    }
    
    @IBAction func clickFavoriteBtn(_ sender: Any) {
        if !self.isOn {
            favoriteButton.setImage(UIImage(named: "btn_favorite_on.png"), for: UIControl.State.normal)
            self.isOn = true
            
            let defaults = UserDefaults.standard
            var array = defaults.array(forKey: "SavedIntArray")  as? [Int] ?? [Int]()
            array.append(place_id)
            defaults.set(array, forKey: "SavedIntArray")
        } else {
            favoriteButton.setImage(UIImage(named: "btn_favorite_off.png"), for: UIControl.State.normal)
            self.isOn = false
            
            let defaults = UserDefaults.standard
            var array = defaults.array(forKey: "SavedIntArray")  as? [Int] ?? [Int]()
            
            if let index = array.index(of: place_id) {
                array.remove(at: index)
            }
            defaults.set(array, forKey: "SavedIntArray")
        }
        
    }
    
    private func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: IndexPath) {
        // When user deselects the cell
    }
  
}
