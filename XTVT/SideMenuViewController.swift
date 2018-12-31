//
//  SideMenuViewController.swift
//  XTVT
//
//  Created by Admin on 12/27/18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

class SideMenuViewController: UIViewController {
    
    @IBOutlet weak var clickAllPalceButton: UIButton!
    @IBOutlet weak var clickFavButton: UIButton!
    @IBOutlet weak var clickNewsButton: UIButton!
    @IBOutlet weak var clickFeatureButton: UIButton!
    @IBOutlet weak var clickTopButton: UIButton!
    @IBOutlet weak var clickLocalButton: UIButton!
    @IBOutlet weak var clickBeachButton: UIButton!
    @IBOutlet weak var clickClimbingButton: UIButton!
    @IBOutlet weak var clickCavingButton: UIButton!
    @IBOutlet weak var clickCulturalButton: UIButton!
    @IBOutlet weak var clickParkButton: UIButton!
    @IBOutlet weak var clickOtherButton: UIButton!
    
    var isClickTwice:Int = 0
    
    @IBOutlet weak var labelCount: UILabel!
    @IBOutlet weak var imageBadge: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        let defaults = UserDefaults.standard
        let array = defaults.array(forKey: "SavedIntArray")  as? [Int] ?? [Int]()
        
        if array.count == 0 {
            self.imageBadge.isHidden = true
            self.labelCount.isHidden = true
        } else {
            self.imageBadge.isHidden = false
            self.labelCount.isHidden = false
            self.labelCount.text = "\(array.count)"
        }
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func clickButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)

        var defaultType = Constants.catNumAll
        
        if sender == self.clickFavButton {
            defaultType = Constants.catNumFavorite
        } else if sender == self.clickNewsButton {
            if let viewController = storyboard?.instantiateViewController(withIdentifier: "NewsTableViewController") as? NewsTableViewController {
                if let navigator = navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }
            }
            return
        } else if sender == self.clickTopButton {
            defaultType = Constants.catNumTopTourist
        } else if sender == self.clickFeatureButton {
            defaultType = Constants.catNumFeatured
        } else if sender == self.clickLocalButton {
            defaultType = Constants.catNumFood
        } else if sender == self.clickBeachButton {
            defaultType = Constants.catNumBeach
        } else if sender == self.clickClimbingButton {
            defaultType = Constants.catNumClimbing
        } else if sender == self.clickCavingButton {
            defaultType = Constants.catNumCaving
        } else if sender == self.clickCulturalButton {
            defaultType = Constants.catNumCultural
        } else if sender == self.clickParkButton {
            defaultType = Constants.catNumPark
        } else if sender == self.clickOtherButton {
            defaultType = Constants.catNumOthers
        }  else if sender == self.clickAllPalceButton {
            defaultType = Constants.catNumAll
        }
        
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "CollectionViewController") as? CollectionViewController {
            if let navigator = navigationController {
                viewController.type = defaultType
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

}
