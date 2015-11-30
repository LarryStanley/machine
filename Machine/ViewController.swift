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

var accountField: UITextField = UITextField()
var passwordField: UITextField = UITextField()
var tableView: UITableView = UITableView()
var moneyData = []
var plusButton: UIButton = UIButton()

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let colorTop = UIColor(red: 72/255.0, green: 129/255.0, blue: 151/255.0, alpha: 1.0).CGColor
        let colorMid = UIColor(red: 46/255.0, green: 116/255.0, blue: 138/255.0, alpha: 1.0).CGColor

        let colorBottom = UIColor(red: 70/255.0, green: 95/255.0, blue: 106/255.0, alpha: 1.0).CGColor
        
        let gradient: CAGradientLayer
        gradient = CAGradientLayer()
        gradient.colors = [colorTop, colorMid, colorBottom]
/*        gradient.startPoint = CGPointMake(0, 0)
        gradient.endPoint = CGPointMake(1, 1)*/
        gradient.locations = [0, 0.7, 1]

        gradient.frame = self.view.bounds
        self.view.layer.insertSublayer(gradient, atIndex: 0)
        
        let keychain = KeychainSwift()
        if ((keychain.get("token")) != nil) {
            self.showUserInterface()
        } else {
            self.showLoginView()
        }
    }
    

    func showLoginView() {
        let accountBorder = CALayer()
        let width = CGFloat(1.0)
        accountBorder.borderColor = UIColor.darkGrayColor().CGColor
        accountBorder.frame = CGRect(x: 0, y: 44 - width, width:  self.view.frame.width - 60, height: 44)
        accountBorder.borderWidth = width
        
        accountField = UITextField(frame: CGRectMake(30, self.view.frame.height/2 - 150, self.view.frame.size.width - 60, 44))
        accountField.placeholder = "帳號"
        accountField.layer.addSublayer(accountBorder)
        accountField.layer.masksToBounds = true
        self.view.addSubview(accountField)
        
        let passwordBorder = CALayer()
        passwordBorder.borderColor = UIColor.darkGrayColor().CGColor
        passwordBorder.frame = CGRect(x: 0, y: 44 - width, width:  self.view.frame.width - 60, height: 44)
        passwordBorder.borderWidth = width
        
        passwordField = UITextField(frame: CGRectMake(30, accountField.frame.height + accountField.frame.origin.y + 10, self.view.frame.size.width - 60, 44))
        passwordField.placeholder = "密碼"
        passwordField.layer.addSublayer(passwordBorder)
        passwordField.layer.masksToBounds = true
        passwordField.secureTextEntry = true
        self.view.addSubview(passwordField)
        
        let loginButton: UIButton
        loginButton = UIButton()
        loginButton.setTitle("登入", forState: .Normal)
        loginButton.sizeToFit()
        loginButton.frame = CGRectMake( 30, passwordField.frame.height + passwordField.frame.origin.y + 20, self.view.frame.size.width - 60, 40)
        loginButton.backgroundColor = UIColor(red: 214/255, green: 230/255, blue: 229/255, alpha: 1)
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
        let menuButton: UIButton
        menuButton = UIButton()
        menuButton.frame = CGRectMake(10, 30, 44, 44)
        //menuButton.titleLabel!.font = UIFont.systemFontOfSize(40)
        //menuButton.setGMDIcon(GMDType.GMDMenu, forState: .Normal)
        menuButton.titleLabel?.font = IonIcons.fontWithSize(40)
        menuButton.setTitle(ion_navicon, forState: .Normal)
        menuButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.view.addSubview(menuButton)
        
        plusButton = UIButton()
        plusButton.frame = CGRectMake( self.view.bounds.width - 54, 30, 44, 44)
        //plusButton.titleLabel!.font = UIFont.systemFontOfSize(40)
        //plusButton.setGMDIcon(GMDType.GMDAdd, forState: .Normal)
        plusButton.titleLabel?.font = IonIcons.fontWithSize(40)
        plusButton.setTitle(ion_ios_plus_empty, forState: .Normal)
        plusButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        plusButton.addTarget(self, action: "showRecordView:", forControlEvents: .TouchUpInside)
        self.view.addSubview(plusButton)
        
        // background circle
        let circleCenter = CGPoint(x: self.view.frame.width/2 ,y: plusButton.frame.origin.y + 130)
        let circlePath = UIBezierPath(arcCenter: circleCenter, radius: CGFloat(80), startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.CGPath
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        shapeLayer.strokeColor = UIColor.whiteColor().CGColor
        shapeLayer.lineWidth = 1.5
        view.layer.addSublayer(shapeLayer)
        
        let radius = CGFloat(80)
        let circle = CAShapeLayer()
        circle.path = UIBezierPath(arcCenter: circleCenter, radius: radius, startAngle: CGFloat(-M_PI_2), endAngle: CGFloat(-M_PI), clockwise: true).CGPath
        circle.fillColor = UIColor.clearColor().CGColor
        circle.strokeColor = UIColor(red: 217/255.0, green: 76/255.0, blue: 58/255.0, alpha: 1).CGColor
        circle.lineWidth = 2.0
        circle.strokeEnd = 1.0
        self.view.layer.addSublayer(circle)
        
        let drawAnimation = CABasicAnimation(keyPath: "strokeEnd")
        drawAnimation.repeatCount = 1.0
        drawAnimation.fromValue = NSNumber(double: 0)
        drawAnimation.toValue = NSNumber(float: 3.0/4.0)
        drawAnimation.duration = 5
        drawAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        circle.addAnimation(drawAnimation, forKey: "animateCircle")
        
        let todayPercentLabel: UILabel
        todayPercentLabel = UILabel()
        todayPercentLabel.text = "64%"
        todayPercentLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 64)
        todayPercentLabel.sizeToFit()
        todayPercentLabel.center = circleCenter
        todayPercentLabel.textColor = UIColor.whiteColor()
        self.view.addSubview(todayPercentLabel)
        
        let lineView: UIView
        lineView = UIView()
        lineView.frame = CGRectMake( 20, circleCenter.y + radius + 20, self.view.frame.width - 40, 1.0);
        lineView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(lineView)
        
        let tableView = UITableView(frame:CGRectMake(10, lineView.frame.origin.y + 10, self.view.frame.size.width - 20, self.view.frame.size.height - lineView.frame.origin.y - 20))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clearColor()
        self.view.addSubview(tableView)
        
        let keychain = KeychainSwift()
        let headers = [
            "x-access-token": keychain.get("token")!
        ]
        
        Alamofire.request(.GET, "http://140.115.26.17:3000/api/history/today", headers: headers)
            .responseJSON{
                response in switch response.result {
                case .Success(let JSON):
                    moneyData = JSON["results"] as! NSArray
                    tableView.reloadData()
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moneyData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.textLabel?.textAlignment = NSTextAlignment.Center
        cell.textLabel?.font = UIFont(name: "System", size: 16)
        cell.textLabel!.text = "\(moneyData.objectAtIndex(indexPath.row)["item"] as! String)"
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

