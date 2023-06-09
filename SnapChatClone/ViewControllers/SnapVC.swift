//
//  SnapVC.swift
//  SnapChatClone
//
//  Created by Altan on 25.05.2023.
//

import UIKit
import ImageSlideshow

class SnapVC: UIViewController {
    
    var selectedSnap : Snap?
    var inputArray = [KingfisherSource]()

    @IBOutlet weak var timeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        if let snap = selectedSnap {
            for imageUrl in snap.imageUrlArray {
                inputArray.append(KingfisherSource(urlString: imageUrl)!)
            }
            
            timeLabel.text = "Time left: \(snap.timeDifference)"
            
            //Image Slide
            let imageSlideShow = ImageSlideshow(frame: CGRect(x: 10, y: 10, width: self.view.frame.width * 0.90, height: self.view.frame.height * 0.85))
            imageSlideShow.backgroundColor = UIColor.white
            
            let pageIndicator = UIPageControl()
            pageIndicator.currentPageIndicatorTintColor = UIColor.lightGray
            pageIndicator.pageIndicatorTintColor = UIColor.black
            imageSlideShow.pageIndicator = pageIndicator
            
            imageSlideShow.contentScaleMode = UIViewContentMode.scaleAspectFit
            imageSlideShow.setImageInputs(inputArray)
            self.view.addSubview(imageSlideShow)
            self.view.bringSubviewToFront(timeLabel) //Time Label her zaman önde gösterilir.
        }
        
    }
    

}
