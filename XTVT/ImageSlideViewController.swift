//
//  ImageSlideViewController.swift
//  XTVT
//
//  Created by Admin on 12/28/18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit
import ImageSlideshow

class ImageSlideViewController: UIViewController {
    @IBOutlet weak var imageSlide: ImageSlideshow!
    
    var detailCV:DetailViewController?
    
    @IBOutlet weak var labelCount: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        let arrayCount:Int = (self.detailCV?.mArrayList?.count)!

        self.labelCount.text = "\(1)/\(arrayCount)"
        imageSlide.slideshowInterval = 5.0
        imageSlide.pageIndicatorPosition = .init(horizontal: .center, vertical: .under)
        imageSlide.contentScaleMode = UIView.ContentMode.scaleAspectFit
        
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = UIColor.red
        pageControl.pageIndicatorTintColor = UIColor.white
        imageSlide.pageIndicator = pageControl
        
        // optional way to show activity indicator during image load (skipping the line will show no activity indicator)
        imageSlide.activityIndicator = DefaultActivityIndicator()
        imageSlide.currentPageChanged = { page in
            self.labelCount.text = "\(page+1)/\(arrayCount)"
        }
        
        // can be used with other sample sources as `afNetworkingSource`, `alamofireSource` or `sdWebImageSource` or `kingfisherSource`
        
        var sdWebImageSource = [SDWebImageSource]()
        for i in 0 ..< arrayCount {
            let info = self.detailCV?.mArrayList?.object(at: i) as! [String:AnyObject]
            let pathName = info["image"] as! String

            let fullPath = Constants.WEB_URL + Constants.getImagePath + pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!

            let SDWebImage = SDWebImageSource(urlString: fullPath)
            
            sdWebImageSource.append(SDWebImage!)
        }
        
        imageSlide.setImageInputs(sdWebImageSource)
        
        //let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        //imageSlide.addGestureRecognizer(recognizer)
        
        // Do any additional setup after loading the view.
    }
    

    @objc func didTap() {
        let fullScreenController = imageSlide.presentFullScreenController(from: self)
        // set the activity indicator for full screen controller (skipping the line will show no activity indicator)
        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
    }
    
    @IBAction func clickClose(_ sender: Any) {
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
