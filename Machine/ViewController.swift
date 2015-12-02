
//
//  ViewController.swift
//  Machine
//
//  Created by LarryStanley on 2015/11/25.
//  Copyright © 2015年 LarryStanley. All rights reserved.
//

import UIKit
import Google_Material_Design_Icons_Swift
import Alamofire
import KeychainSwift
import ionicons
import Hex
import SwiftLocation

class ViewController: UIViewController {
    
    var accountField: UITextField = UITextField()
    var passwordField: UITextField = UITextField()
    var tableView: UITableView = UITableView()
    var moneyData = []
    var plusButton: UIButton = UIButton()
    var mainScrollView: UIScrollView = UIScrollView()
    var todayPercentLabel = UILabel()
    var transparentView = UIView()
    var lineBetweenDetailView = UIView()
    var unitLabel = UILabel()
    var allItems = NSMutableArray()
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let colorTop = UIColor(red: 66/255.0, green: 76/255.0, blue: 121/255.0, alpha: 1.0).CGColor
        let colorBottom = UIColor(red: 145/255.0, green: 133/255.0, blue: 161/255.0, alpha: 1.0).CGColor
        
        let gradient: CAGradientLayer
        gradient = CAGradientLayer()
        gradient.colors = [colorTop, colorBottom]
        gradient.startPoint = CGPointMake(0, 0)
        gradient.endPoint = CGPointMake(1, 1)
        gradient.locations = [0, 1]

        gradient.frame = self.view.bounds
        navigationController?.view.layer.insertSublayer(gradient, atIndex: 0)
        self.view.backgroundColor = UIColor.clearColor()
        //self.view.layer.insertSublayer(gradient, atIndex: 0)
        
        let keychain = KeychainSwift()
        if ((keychain.get("token")) != nil) {
            self.showUserInterface()
        } else {
            self.showLoginView()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    

    func showLoginView() {
        let accountBorder = CALayer()
        let width = CGFloat(1.0)
        accountBorder.borderColor = UIColor.darkGrayColor().CGColor
        accountBorder.frame = CGRect(x: 0, y: 44 - width, width:  self.view.frame.width - 60, height: 44)
        accountBorder.borderWidth = width
        
        accountField = UITextField(frame: CGRectMake(30, self.view.frame.height/2 - 150, self.view.frame.size.width - 60, 44))
        accountField.placeholder = "帳號"
        accountField.attributedPlaceholder = NSAttributedString(string:"帳號", attributes:[NSForegroundColorAttributeName: UIColor(hex: "CFD8DC")])
        accountField.layer.addSublayer(accountBorder)
        accountField.layer.masksToBounds = true
        self.view.addSubview(accountField)
        
        let passwordBorder = CALayer()
        passwordBorder.borderColor = UIColor.darkGrayColor().CGColor
        passwordBorder.frame = CGRect(x: 0, y: 44 - width, width:  self.view.frame.width - 60, height: 44)
        passwordBorder.borderWidth = width
        
        passwordField = UITextField(frame: CGRectMake(30, accountField.frame.height + accountField.frame.origin.y + 10, self.view.frame.size.width - 60, 44))
        passwordField.placeholder = "密碼"
        passwordField.attributedPlaceholder = NSAttributedString(string:"密碼", attributes:[NSForegroundColorAttributeName: UIColor(hex: "CFD8DC")])
        passwordField.layer.addSublayer(passwordBorder)
        passwordField.layer.masksToBounds = true
        passwordField.secureTextEntry = true
        self.view.addSubview(passwordField)
        
        let loginButton: UIButton
        loginButton = UIButton()
        loginButton.setTitle("登入", forState: .Normal)
        loginButton.sizeToFit()
        loginButton.frame = CGRectMake( 30, passwordField.frame.height + passwordField.frame.origin.y + 20, self.view.frame.size.width - 60, 40)
        loginButton.backgroundColor = UIColor(hex: "ECEFF1")
        loginButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        loginButton.addTarget(self, action: "processLogin:", forControlEvents: .TouchUpInside)
        self.view.addSubview(loginButton)
    }
    
    func processLogin(sender: UIButton) {

        let name: String = accountField.text!
        let password: String = passwordField.text!
        
        let data = [
            "name": name,
            "password": password
        ]
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        Alamofire.request(.POST, "http://140.115.26.17:3000/api/authenticate", parameters: data, headers: headers)
            .responseJSON{
                response in switch response.result {
                    case .Success(let JSON):
                        let keychain = KeychainSwift()
                        keychain.set(data["name"]!, forKey: "name")
                        keychain.set(data["password"]!, forKey: "password")
                        keychain.set(JSON["token"]! as! String, forKey: "token")
                    case .Failure(let error):
                        print("Request failed with error: \(error)")
                }
            }
    }

    func showUserInterface() {
        
        /*let menuButton: UIButton
        menuButton = UIButton()
        menuButton.frame = CGRectMake(10, 30, 44, 44)
        menuButton.titleLabel?.font = IonIcons.fontWithSize(40)
        menuButton.setTitle(ion_navicon, forState: .Normal)
        menuButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.view.addSubview(menuButton)*/
        
        mainScrollView = UIScrollView(frame: self.view.frame)
        self.view.addSubview(mainScrollView)
        
        let attributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        let attributedTitle = NSAttributedString(string: "下拉更新", attributes: attributes)
        refreshControl.attributedTitle = attributedTitle
        refreshControl.addTarget(self, action: "getTodayData", forControlEvents: UIControlEvents.ValueChanged)
        refreshControl.tintColor = UIColor.whiteColor()
        mainScrollView.addSubview(refreshControl)
        
        let todayLabel = UILabel()
        todayLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 36)
        let now = NSDate()
        todayLabel.textColor = UIColor(hex: "#ECEFF1")
        todayLabel.text = now.stringFromFormat("MM/dd")
        todayLabel.sizeToFit()
        //todayLabel.frame = CGRectMake(self.view.frame.size.width/2 - todayLabel.frame.size.width/2, 30, todayLabel.frame.width, todayLabel.frame.height)
        todayLabel.frame = CGRectMake(10, 0, todayLabel.frame.width, todayLabel.frame.height)
        mainScrollView.addSubview(todayLabel)
        
        self.title = now.stringFromFormat("MM/dd")
        
        transparentView = UIView(frame: CGRectMake(0, self.view.frame.height - 80, self.view.frame.width, 80))
        transparentView.backgroundColor = UIColor(hex: "263238")
        transparentView.alpha = 0.4
        mainScrollView.addSubview(transparentView)
        
        todayPercentLabel = UILabel()
        todayPercentLabel.text = "0"
        todayPercentLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 90)
        todayPercentLabel.sizeToFit()
        //todayPercentLabel.center = circleCenter
        todayPercentLabel.frame = CGRectMake(10, transparentView.frame.origin.y - todayPercentLabel.frame.size.height, todayPercentLabel.frame.size.width , todayPercentLabel.frame.size.height)
        todayPercentLabel.textColor = UIColor.whiteColor()
        mainScrollView.addSubview(todayPercentLabel)
        
        let todayOverAllLable: UILabel
        todayOverAllLable = UILabel()
        todayOverAllLable.text = "今日花費"
        todayOverAllLable.font = UIFont(name: "HelveticaNeue", size: 18)
        todayOverAllLable.sizeToFit()
        //todayPercentLabel.center = circleCenter
        todayOverAllLable.frame = CGRectMake(20, todayPercentLabel.frame.origin.y - todayOverAllLable.frame.size.height, todayOverAllLable.frame.size.width , todayOverAllLable.frame.size.height)
        todayOverAllLable.textColor = UIColor.whiteColor()
        mainScrollView.addSubview(todayOverAllLable)
        
        unitLabel.text = "NTD"
        unitLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 18)
        unitLabel.sizeToFit()
        unitLabel.textColor = UIColor.whiteColor()
        mainScrollView.addSubview(unitLabel)
        
        let textButton = UIButton()
        textButton.frame = CGRectMake( self.view.bounds.width/2 - 54, 5, 44, 44)
        textButton.titleLabel!.font = IonIcons.fontWithSize(40)
        textButton.setTitle(ion_ios_compose_outline, forState: .Normal)
        textButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        textButton.addTarget(self, action: "showTextRecord:", forControlEvents: .TouchUpInside)
        transparentView.addSubview(textButton)
        
        let qrCodeButton = UIButton()
        qrCodeButton.frame = CGRectMake( self.view.bounds.width/2 + 10, 5, 44, 44)
        qrCodeButton.titleLabel!.font = IonIcons.fontWithSize(40)
        qrCodeButton.setTitle(ion_ios_barcode_outline, forState: .Normal)
        qrCodeButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        qrCodeButton.addTarget(self, action: "showCodeRecord:", forControlEvents: .TouchUpInside)
        transparentView.addSubview(qrCodeButton)
        
        lineBetweenDetailView = UIView(frame: CGRectMake( 20, textButton.frame.origin.y + textButton.frame.size.height + 15, self.view.bounds.width - 40, 1));
        lineBetweenDetailView.backgroundColor = UIColor(hex: "ECEFF1")
        transparentView.addSubview(lineBetweenDetailView)

        self.getTodayData()
    }
    
    func showTextRecord(sender: UIButton) {
        let textRecordView = RecordView(frame: self.view.frame)
        textRecordView.alpha = 0;
        self.view.addSubview(textRecordView)
        UIView.animateWithDuration(0.3, animations: {
            textRecordView.alpha = 1
        })
    }
    
    func showCodeRecord(sender: UIButton) {
        let codeRecordView = QRCodeScannerView(frame: self.view.frame)
        codeRecordView.alpha = 0
        self.view.addSubview(codeRecordView)
        UIView.animateWithDuration(0.3, animations: {
            codeRecordView.alpha = 1
        })
    }
    
    func getTodayData() {
        let keychain = KeychainSwift()
        let headers = [
            "x-access-token": keychain.get("token")!
        ]
        
        Alamofire.request(.GET, "http://140.115.26.17:3000/api/history/today", headers: headers)
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
                        let singleView = SingleItemView(frame: CGRectMake(0, lastY, self.view.frame.size.width, 70), time: item["time"]! as! String, item: item["item"]! as! String, amount: item["amount"]! as! Int, navigationController: self.navigationController!, allData: item as! NSDictionary)
                        self.transparentView.addSubview(singleView)
                        lastHeight = singleView.frame.size.height + singleView.frame.origin.y
                        lastY = lastHeight
                        self.allItems.addObject(singleView)
                    }
                    
                    self.mainScrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.transparentView.frame.origin.y + lastHeight)
                    self.transparentView.frame = CGRectMake(self.transparentView.frame.origin.x, self.transparentView.frame.origin.y, self.transparentView.frame.size.width, lastHeight + self.view.frame.size.height)
                    
                    self.refreshControl.endRefreshing()
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                }
        }

    }
    
    func showRecordView(sender: UIButton) {
        let recordView: RecordView
        recordView = RecordView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.height))
        self.view.addSubview(recordView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

