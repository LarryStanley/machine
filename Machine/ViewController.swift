
//
//  ViewController.swift
//  Machine
//
//  Created by LarryStanley on 2015/11/25.
//  Copyright © 2015年 LarryStanley. All rights reserved.
//

import UIKit
import Alamofire
import KeychainSwift
import ionicons
import Hex
import SwiftLocation
import Material

class ViewController: UIViewController {
    
    var accountField: UITextField = UITextField()
    var passwordField: UITextField = UITextField()
    
    private var modeMenu: Menu!
    
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
        
        let singleDay = SingleDayScrollView(frame: self.view.frame, date: NSDate())
        singleDay.navigationController = self.navigationController!
        self.view.addSubview(singleDay)
        
        let modeButton: FlatButton = FlatButton()
        modeButton.titleLabel!.font = IonIcons.fontWithSize(30)
        modeButton.setTitle(ion_ios_more_outline, forState: .Normal)
        modeButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        modeButton.addTarget(self, action: "handleModeMenu", forControlEvents: .TouchUpInside)
        modeButton.pulseColor = MaterialColor.white
        self.view.addSubview(modeButton)
        
        let dayButton: FlatButton = FlatButton()
        dayButton.setTitleColor(MaterialColor.white, forState: .Normal)
        dayButton.borderColor = MaterialColor.white
        dayButton.pulseColor = MaterialColor.white
        dayButton.borderWidth = 0.5
        dayButton.setTitle("天", forState: .Normal)
        self.view.addSubview(dayButton)
        
        let weekButton: FlatButton = FlatButton()
        weekButton.setTitleColor(MaterialColor.white, forState: .Normal)
        weekButton.borderColor = MaterialColor.white
        weekButton.pulseColor = MaterialColor.white
        weekButton.borderWidth = 0.5
        weekButton.setTitle("週", forState: .Normal)
        self.view.addSubview(weekButton)
        
        let monthButton: FlatButton = FlatButton()
        monthButton.setTitleColor(MaterialColor.white, forState: .Normal)
        monthButton.borderColor = MaterialColor.white
        monthButton.pulseColor = MaterialColor.white
        monthButton.borderWidth = 0.5
        monthButton.setTitle("月", forState: .Normal)
        self.view.addSubview(monthButton)
        
        modeMenu = Menu(origin: CGPointMake(self.view.frame.size.width - 65, 20))
        modeMenu.direction = .Down
        modeMenu.spacing = 8
        modeMenu.itemViewSize = CGSizeMake(60, 44)
        modeMenu.views = [modeButton, dayButton, weekButton, monthButton]
    }
    
    internal func handleModeMenu() {
        // Only trigger open and close animations when enabled.
        if modeMenu.enabled {
            if modeMenu.opened {
                modeMenu.close()
            } else {
                modeMenu.open()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

