//
//  SingleDayScrollView.swift
//  Machine
//
//  Created by LarryStanley on 2015/12/3.
//  Copyright © 2015年 LarryStanley. All rights reserved.
//

import UIKit
import Alamofire
import KeychainSwift
import ionicons
import Hex
import SwiftLocation
import Timepiece
import Material

class SingleDayScrollView: UIScrollView, RecordViewFinishDelegate, QRCodeViewDelegate, SingleItemViewDelegate{

    var todayPercentLabel = UILabel()
    var transparentView = UIView()
    var lineBetweenDetailView = UIView()
    var unitLabel = UILabel()
    var allItems = NSMutableArray()
    var refreshControl = UIRefreshControl()
    var moneyData = []
    var navigationController = UINavigationController()
    var nextDayButton = FlatButton()
    var previousDayButton = FlatButton()
    var todayLabel = UILabel()
    var currentDate = NSDate()
    
    init(frame: CGRect, date: NSDate) {
        super.init(frame: frame)
        
        let attributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        let attributedTitle = NSAttributedString(string: "下拉更新", attributes: attributes)
        refreshControl.attributedTitle = attributedTitle
        refreshControl.addTarget(self, action: "getTodayData", forControlEvents: UIControlEvents.ValueChanged)
        refreshControl.tintColor = UIColor.whiteColor()
        self.addSubview(refreshControl)
        
        todayLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 24)
        todayLabel.textColor = UIColor(hex: "#ECEFF1")
        todayLabel.text = date.stringFromFormat("MM/dd\nEEEE")
        todayLabel.numberOfLines = 0
        todayLabel.sizeToFit()
        //todayLabel.frame = CGRectMake(self.view.frame.size.width/2 - todayLabel.frame.size.width/2, 30, todayLabel.frame.width, todayLabel.frame.height)
        todayLabel.frame = CGRectMake(0, 0, todayLabel.frame.width, todayLabel.frame.height)
        todayLabel.frame.origin.x = self.frame.size.width/2 - todayLabel.frame.width/2
        self.addSubview(todayLabel)
        currentDate = date
        
        nextDayButton.frame = CGRectMake( todayLabel.frame.origin.x + todayLabel.frame.size.width + 2, 0, 44, 44)
        nextDayButton.titleLabel!.font = IonIcons.fontWithSize(30)
        nextDayButton.setTitle(ion_ios_arrow_right, forState: .Normal)
        nextDayButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        nextDayButton.addTarget(self, action: "showNextDay:", forControlEvents: .TouchUpInside)
        nextDayButton.center.y = todayLabel.center.y
        nextDayButton.alpha = 0
        self.addSubview(nextDayButton)
        
        previousDayButton.frame = CGRectMake( todayLabel.frame.origin.x - 46, 0, 44, 44)
        previousDayButton.titleLabel!.font = IonIcons.fontWithSize(30)
        previousDayButton.setTitle(ion_ios_arrow_left, forState: .Normal)
        previousDayButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        previousDayButton.center.y = todayLabel.center.y
        previousDayButton.addTarget(self, action: "showPreviousDay:", forControlEvents: .TouchUpInside)
        self.addSubview(previousDayButton)
        
        transparentView = UIView(frame: CGRectMake(0, self.frame.height - 80, self.frame.width, 80))
        transparentView.backgroundColor = UIColor(hex: "263238")
        transparentView.alpha = 0.4
        self.addSubview(transparentView)
        
        todayPercentLabel = UILabel()
        todayPercentLabel.text = "0"
        todayPercentLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 90)
        todayPercentLabel.sizeToFit()
        //todayPercentLabel.center = circleCenter
        todayPercentLabel.frame = CGRectMake(10, transparentView.frame.origin.y - todayPercentLabel.frame.size.height, todayPercentLabel.frame.size.width , todayPercentLabel.frame.size.height)
        todayPercentLabel.textColor = UIColor.whiteColor()
        self.addSubview(todayPercentLabel)
        
        let todayOverAllLable: UILabel
        todayOverAllLable = UILabel()
        todayOverAllLable.text = "總花費"
        todayOverAllLable.font = UIFont(name: "HelveticaNeue", size: 18)
        todayOverAllLable.sizeToFit()
        //todayPercentLabel.center = circleCenter
        todayOverAllLable.frame = CGRectMake(20, todayPercentLabel.frame.origin.y - todayOverAllLable.frame.size.height, todayOverAllLable.frame.size.width , todayOverAllLable.frame.size.height)
        todayOverAllLable.textColor = UIColor.whiteColor()
        self.addSubview(todayOverAllLable)
        
        unitLabel.text = "NTD"
        unitLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 18)
        unitLabel.sizeToFit()
        unitLabel.textColor = UIColor.whiteColor()
        self.addSubview(unitLabel)
        
        let textButton = FlatButton()
        textButton.frame = CGRectMake( self.bounds.width/2 - 75, 5, 65, 44)
        textButton.titleLabel!.font = IonIcons.fontWithSize(40)
        textButton.setTitle(ion_ios_compose_outline, forState: .Normal)
        textButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        textButton.addTarget(self, action: "showTextRecord:", forControlEvents: .TouchUpInside)
        transparentView.addSubview(textButton)
        
        let qrCodeButton = FlatButton()
        qrCodeButton.frame = CGRectMake( self.bounds.width/2 + 10, 5, 65, 44)
        qrCodeButton.titleLabel!.font = IonIcons.fontWithSize(40)
        qrCodeButton.setTitle(ion_ios_barcode_outline, forState: .Normal)
        qrCodeButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        qrCodeButton.addTarget(self, action: "showCodeRecord:", forControlEvents: .TouchUpInside)
        transparentView.addSubview(qrCodeButton)
        
        lineBetweenDetailView = UIView(frame: CGRectMake( 20, textButton.frame.origin.y + textButton.frame.size.height + 15, self.bounds.width - 40, 1));
        lineBetweenDetailView.backgroundColor = UIColor(hex: "ECEFF1")
        transparentView.addSubview(lineBetweenDetailView)
        
        self.getTodayData()
        
    }
    
    func showTextRecord(sender: UIButton) {
        let textRecordView = RecordView(frame: self.frame)
        textRecordView.alpha = 0;
        textRecordView.delegate = self
        self.window!.addSubview(textRecordView)
        UIView.animateWithDuration(0.3, animations: {
            textRecordView.alpha = 1
        })
    }
    
    func recordFinish(view: RecordView) {
        self.getTodayData()
    }
    
    func showCodeRecord(sender: UIButton) {
        let codeRecordView = QRCodeScannerView(frame: self.frame)
        codeRecordView.alpha = 0
        codeRecordView.delegate = self
        self.window!.addSubview(codeRecordView)
        UIView.animateWithDuration(0.3, animations: {
            codeRecordView.alpha = 1
        })
    }
    
    func CodeRecordFinish(view: QRCodeScannerView) {
        self.getTodayData()
    }
    
    func showNextDay(sender: UIButton) {
        self.currentDate = self.currentDate + 1.day
        UIView.animateWithDuration(0.3, animations: {
            self.todayLabel.text = self.currentDate.stringFromFormat("MM/dd\nEEEE")
            if (self.currentDate.stringFromFormat("yyyy-MM-dd") == NSDate().stringFromFormat("yyyy-MM-dd")) {
                self.nextDayButton.alpha = 0
            }
        })
        self.getTodayData()
    }
    
    func showPreviousDay(sender: UIButton) {
        self.currentDate = self.currentDate - 1.day
        UIView.animateWithDuration(0.3, animations: {
            self.todayLabel.text = self.currentDate.stringFromFormat("MM/dd\nEEEE")
            if (self.currentDate.stringFromFormat("yyyy-MM-dd") != NSDate().stringFromFormat("yyyy-MM-dd")) {
                self.nextDayButton.alpha = 1
            }
        })
        self.getTodayData()
    }
    
    func getTodayData() {
        let keychain = KeychainSwift()
        let headers = [
            "x-access-token": keychain.get("token")!
        ]
        
        
        Alamofire.request(.GET, "http://140.115.26.17:3000/api/history/date/\(currentDate.stringFromFormat("yyyy-MM-dd"))", headers: headers)
            .responseJSON{
                response in switch response.result {
                case .Success(let JSON):
                    for item in self.allItems {
                        item.removeFromSuperview()
                    }
                    
                    self.moneyData = JSON["results"] as! NSArray
                    //tableView.reloadData()
                    self.todayPercentLabel.text? = "\(JSON["total_amount"] as! Int)"
                    self.todayPercentLabel.sizeToFit()
                    
                    //todayPercentLabel.center = circleCenter
                    self.unitLabel.frame = CGRectMake( self.todayPercentLabel.frame.size.width + self.todayPercentLabel.frame.origin.x + 5, self.transparentView.frame.origin.y - self.unitLabel.frame.size.height - 15, self.unitLabel.frame.size.width , self.unitLabel.frame.size.height)
                    
                    var lastY = self.lineBetweenDetailView.frame.origin.y + self.lineBetweenDetailView.frame.size.height + 5
                    var lastHeight = CGFloat(100)
                    for item in self.moneyData.reverse() {
                        let singleView = SingleItemView(frame: CGRectMake(0, lastY, self.frame.size.width, 70), time: item["time"]! as! String, item: item["item"]! as! String, amount: item["amount"]! as! Int, navigationController: self.navigationController, allData: item as! NSDictionary)
                        self.transparentView.addSubview(singleView)
                        singleView.updateDelegate = self
                        lastHeight = singleView.frame.size.height + singleView.frame.origin.y
                        lastY = lastHeight
                        self.allItems.addObject(singleView)
                    }
                    
                    self.contentSize = CGSizeMake(self.frame.size.width, self.transparentView.frame.origin.y + lastHeight)
                    self.transparentView.frame = CGRectMake(self.transparentView.frame.origin.x, self.transparentView.frame.origin.y, self.transparentView.frame.size.width, lastHeight + self.frame.size.height)
                    
                    self.refreshControl.endRefreshing()
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                }
        }
        
    }
    
    func updateData(view: SingleItemView) {
        self.getTodayData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
