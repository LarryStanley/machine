//
//  SingleItemView.swift
//  Machine
//
//  Created by LarryStanley on 2015/11/30.
//  Copyright © 2015年 LarryStanley. All rights reserved.
//

import UIKit
import Timepiece
import ionicons
import Hex

class SingleItemView: UIButton {
    
    var allLabel:[UILabel] = []
    var superNavigationController = UINavigationController()
    var circleLabel = UILabel()

    var itemData = NSDictionary()
    
    init(frame: CGRect, time: String, item: String, amount: Int, navigationController: UINavigationController, allData: NSDictionary) {
        super.init(frame: frame)
        
        superNavigationController = navigationController
        
        var timeParser = time.dateFromFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ")
        let userTimeZone = NSTimeZone.localTimeZone()
        timeParser = timeParser?.change(timeZone: userTimeZone)
        
        let timeLabel = UILabel(frame: CGRectMake( 10, 10, 0, 0))
        timeLabel.textColor = UIColor(hex: "ECEFF1")
        timeLabel.text = timeParser?.stringFromFormat("HH:mm")
        timeLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 20)
        timeLabel.sizeToFit()
        self.addSubview(timeLabel)
        allLabel.append(timeLabel)
        
        circleLabel = UILabel(frame: CGRectMake(timeLabel.frame.size.width + timeLabel.frame.origin.x + 15, 10, 0, 0))
        circleLabel.font = IonIcons.fontWithSize(28)
        circleLabel.textColor = UIColor(hex: "ECEFF1")
        circleLabel.text = ion_ios_circle_filled
        circleLabel.sizeToFit()
        circleLabel.center = CGPointMake(timeLabel.frame.size.width + timeLabel.frame.origin.x + 20, timeLabel.center.y)
        self.addSubview(circleLabel)
        allLabel.append(circleLabel)
        
        let itemLabel = UILabel()
        itemLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 22)
        itemLabel.textColor = UIColor(hex: "ECEFF1")
        itemLabel.text = item
        itemLabel.sizeToFit()
        itemLabel.center = CGPointMake(0, circleLabel.center.y)
        itemLabel.frame.origin.x = circleLabel.frame.origin.x + circleLabel.frame.size.width + 10
        self.addSubview(itemLabel)
        allLabel.append(itemLabel)
        
        let amountLabel = UILabel()
        amountLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 20)
        amountLabel.text = "\(amount) NTD"
        amountLabel.textColor = UIColor(hex: "ECEFF1")
        amountLabel.sizeToFit()
        amountLabel.frame.origin.x = itemLabel.frame.origin.x
        amountLabel.frame.origin.y = itemLabel.frame.origin.y + itemLabel.frame.size.height + 5
        self.addSubview(amountLabel)
        allLabel.append(amountLabel)
        
        self.addTarget(self, action: "showDetailViews", forControlEvents: .TouchUpInside)
        self.addTarget(self, action: "showPressAnimation", forControlEvents: .TouchDown)
        self.addTarget(self, action: "returnToOriginal", forControlEvents: .TouchUpOutside)
        
        itemData = allData
    }

    func returnToOriginal() {
        UIView.animateWithDuration(0.5, animations: {
            self.backgroundColor = UIColor.clearColor()
            self.alpha = 1
            
            for item in self.allLabel{
                item.textColor = UIColor(hex: "#B0BEC5")
            }
        })

    }
    
    func showPressAnimation() {
        
        UIView.animateWithDuration(0.2, animations: {
            self.backgroundColor = UIColor(hex: "#37474F")
            self.alpha = 0.7
            
            for item in self.allLabel{
                item.textColor = UIColor(hex: "#FAFAFA")
            }
        })
    }
    
    func showDetailViews() {
        UIView.animateWithDuration(0.5, animations: {
            self.backgroundColor = UIColor.clearColor()
            self.alpha = 1
            
            for item in self.allLabel{
                item.textColor = UIColor(hex: "#ECEFF1")
            }
        })
        
        let detailViewController = DetailViewController()
        detailViewController.itemData = itemData
        superNavigationController.pushViewController(detailViewController, animated: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
