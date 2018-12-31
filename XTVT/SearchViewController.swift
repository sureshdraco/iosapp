//
//  SearchViewController.swift
//  XTVT
//
//  Created by Admin on 12/29/18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITextFieldDelegate, UICollectionViewDelegate,  UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var editTextKey: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    var mArrayList:NSMutableArray?

    var collectionVC:CollectionViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mArrayList = NSMutableArray()

        // Do any additional setup after loading the view.
    }
    
    func searchData(keyword: String) {
        if keyword == "" {
            return;
        }
        
        self.mArrayList = NSMutableArray()
        let arrayCount:Int = (self.collectionVC?.mArrayList?.count)!
        
        for i in 0 ..< arrayCount {
            let item:NSDictionary = self.collectionVC?.mArrayList?.object(at: i) as! NSDictionary
            let name = item.object(forKey: "name") as! String
            if name.lowercased().contains(keyword) {
                self.mArrayList?.add(item)
            }
        }
        
        collectionView.reloadData()
    }
    
    @IBAction func closeButton(_ sender: Any) {
        editTextKey.text = ""
    }
    
    @IBAction func backButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
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
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
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
    
    //TextField Delegate Func Define
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.searchData(keyword: textField.text ?? "")
        textField.resignFirstResponder()
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidChange(_ textField: UITextField) {
    }
}
