//
//  MapViewController.swift
//  XTVT
//
//  Created by Admin on 12/28/18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit
import MapKit
import SideMenu

class MapViewController: UIViewController {
    var detailCV:DetailViewController?

    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var labelTitle: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        
        labelTitle.text = self.detailCV!.textTitleString
        let annotation = MKPointAnnotation()
        annotation.title = self.detailCV!.textTitleString
        annotation.coordinate = (self.detailCV?.coordinate)!
        
        var region = MKCoordinateRegion()
        var span = MKCoordinateSpan()
        
        span.latitudeDelta = 0.5     // 0.0 is min value u van provide for zooming
        span.longitudeDelta = 0.5
        region.span=span;
        region.center = (self.detailCV?.coordinate)!;     // to locate to the center
        self.map.addAnnotation(annotation)
        self.map.setRegion(region, animated: true)
        self.map.regionThatFits(region)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func sideMenuClick(_ sender: Any) {
        SideMenuManager.default.menuLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? UISideMenuNavigationController
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }
    
    @IBAction func clickBack(_ sender: Any) {
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

}
