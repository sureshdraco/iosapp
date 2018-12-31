//
//  NewsDetailViewController.swift
//  XTVT
//
//  Created by Admin on 12/28/18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

class NewsDetailViewController: UIViewController {
    
    var detailInfo:NSDictionary? = nil

    @IBOutlet weak var heightParentView: NSLayoutConstraint!
    @IBOutlet weak var heightTextView: NSLayoutConstraint!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelDate: UILabel!
    
    @IBOutlet weak var textViewDetail: UITextView!
    
    @IBOutlet weak var textTitle: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.textTitle.text = detailInfo!.object(forKey: "title") as? String
        let pathName = detailInfo!.object(forKey: "image") as! String
        let fullPath = Constants.WEB_URL + Constants.getNewsImagePath + pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        getData(from: URL(string: fullPath)!) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                self.imageView.image = UIImage(data: data)
                
            }
        }
        
        
        let htmlText = detailInfo!.object(forKey: "full_content") as? String
        let encodedData = htmlText!.data(using: String.Encoding.utf8)!
        var attributedString: NSAttributedString
        
        do {
            attributedString = try NSAttributedString(data: encodedData, options: [NSAttributedString.DocumentReadingOptionKey.documentType:NSAttributedString.DocumentType.html,NSAttributedString.DocumentReadingOptionKey.characterEncoding:NSNumber(value: String.Encoding.utf8.rawValue)], documentAttributes: nil)
            self.textViewDetail.attributedText = attributedString
            
            //change description size
            let sizeToFitIn = CGSize(width: self.textViewDetail.bounds.size.width, height:CGFloat(MAXFLOAT))
            let newSize = self.textViewDetail.sizeThatFits(sizeToFitIn)
            self.heightTextView.constant = self.heightTextView.constant  - 300.0 + newSize.height
            self.heightParentView.constant = self.heightParentView.constant - 300.0 + newSize.height
        } catch let error as NSError {
            print(error.localizedDescription)
        } catch {
            print("error")
        }
        
        let timeResult = detailInfo!.object(forKey: "last_update") as? Double
        let date = Date(timeIntervalSince1970: timeResult! / 1000)
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        labelDate.text = dateFormatter.string(from: date)
        // Do any additional setup after loading the view.
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    
    @IBAction func clickBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)

    }
    
    @IBAction func clickShare(_ sender: Any) {
        let text = self.textViewDetail.text
        let image = self.imageView.image
        let shareAll = [text as Any , image!]
        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
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
