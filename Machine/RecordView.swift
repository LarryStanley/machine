//
//  RecordView.swift
//  Machine
//
//  Created by LarryStanley on 2015/11/29.
//  Copyright © 2015年 LarryStanley. All rights reserved.
//

import UIKit
import Google_Material_Design_Icons_Swift
import ionicons
import SwiftLocation
import KeychainSwift
import Alamofire
import Hex

protocol RecordViewFinishDelegate {
    func recordFinish(view: RecordView)
}

class RecordView: UIView, UITextFieldDelegate {
    
    var itemField = UITextField()
    var amountField = UITextField()
    var mainView = UIScrollView()
    var textButton = UIButton()
    var currentStat = "text"
    var recordButton = UIButton()
    var delegate:RecordViewFinishDelegate! = nil

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let colorTop = UIColor(red: 33/255.0, green: 121/255.0, blue: 122/255.0, alpha: 1.0).CGColor
        let colorBottom = UIColor(red: 136/255.0, green: 158/255.0, blue: 138/255.0, alpha: 1.0).CGColor
        
        let gradient: CAGradientLayer
        gradient = CAGradientLayer()
        gradient.colors = [colorTop, colorBottom]
        gradient.startPoint = CGPointMake(0, 0)
        gradient.endPoint = CGPointMake(1, 1)
        gradient.locations = [0, 1]
        
        gradient.frame = self.bounds
        self.layer.insertSublayer(gradient, atIndex: 0)
        
        let clearButton: UIButton
        clearButton = UIButton()
        clearButton.frame = CGRectMake( self.bounds.width - 54, 30, 44, 44)
        //clearButton.titleLabel!.font = UIFont.systemFontOfSize(40)
        //clearButton.setGMDIcon(GMDType.GMDClear, forState: .Normal)
        clearButton.titleLabel?.font = IonIcons.fontWithSize(50)
        clearButton.setTitle(ion_ios_close_empty, forState: .Normal)
        clearButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        clearButton.addTarget(self, action: "cancelView:", forControlEvents: .TouchUpInside)
        self.addSubview(clearButton)
        
        let itemBorder = CALayer()
        let width = CGFloat(1.0)
        itemBorder.borderColor = UIColor(red: 55/255, green: 71/255, blue: 79/255, alpha: 1).CGColor
        itemBorder.frame = CGRect(x: 0, y: 44 - width, width:  self.frame.width - 60, height: 44)
        itemBorder.borderWidth = width
        
        itemField = UITextField(frame: CGRectMake(30, clearButton.frame.height + clearButton.frame.origin.y + 30, self.frame.size.width - 60, 44))
        itemField.placeholder = "品項"
        itemField.layer.addSublayer(itemBorder)
        itemField.layer.masksToBounds = true
        itemField.delegate = self
        itemField.returnKeyType = .Done
        itemField.textColor = UIColor(hex: "#ECEFF1")
        itemField.attributedPlaceholder = NSAttributedString(string:"品項", attributes:[NSForegroundColorAttributeName: UIColor(hex: "#B0BEC5")])
        self.addSubview(itemField)
        
        let amountBorder = CALayer()
        amountBorder.borderColor = UIColor(red: 55/255, green: 71/255, blue: 79/255, alpha: 1).CGColor
        amountBorder.frame = CGRect(x: 0, y: 44 - width, width:  self.frame.width - 60, height: 44)
        amountBorder.borderWidth = width
        
        amountField = UITextField(frame: CGRectMake(30, itemField.frame.height + itemField.frame.origin.y + 10, self.frame.size.width - 60, 44))
        amountField.placeholder = "價錢"
        amountField.layer.addSublayer(amountBorder)
        amountField.layer.masksToBounds = true
        amountField.delegate = self
        amountField.keyboardType = .NumberPad
        amountField.returnKeyType = .Done
        amountField.textColor = UIColor(hex: "#ECEFF1")
        amountField.attributedPlaceholder = NSAttributedString(string:"價錢", attributes:[NSForegroundColorAttributeName: UIColor(hex: "#B0BEC5")])
        self.addSubview(amountField)
        
        recordButton = UIButton()
        recordButton.setTitle("紀錄", forState: .Normal)
        recordButton.sizeToFit()
        recordButton.frame = CGRectMake( 30, amountField.frame.height + amountField.frame.origin.y + 20, self.frame.size.width - 60, 40)
        recordButton.backgroundColor = UIColor(red: 214/255, green: 230/255, blue: 229/255, alpha: 1)
        recordButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        recordButton.addTarget(self, action: "recordData:", forControlEvents: .TouchUpInside)
        self.addSubview(recordButton)
    }

    func cancelView(sender: UIButton) {
        UIView.animateWithDuration(0.3, animations: {
                self.alpha = 0
            }, completion: { finished in
                self.removeFromSuperview()
        })
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        let color = CABasicAnimation(keyPath: "borderColor")
        color.fromValue = textField.layer.borderColor
        color.toValue = UIColor(hex: "#F44336").CGColor
        color.duration = 2
        color.repeatCount = 1
        textField.layer.addAnimation(color, forKey: "borderColor")
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func recordData(sender: UIButton) {
        do {
            try SwiftLocation.shared.currentLocation(Accuracy.Block, timeout: 60, onSuccess: { (location) -> Void in
                
                print("1. Location found \(location?.description)")
            
                let keychain = KeychainSwift()
                let headers = [
                    "x-access-token": keychain.get("token")!
                ]
            
                let item = self.itemField.text!
                let amount = self.amountField.text!
            
                let data : [String: AnyObject] = [
                    "item": item,
                    "amount": amount,
                    "latitude": (location?.coordinate.latitude)!,
                    "longitude": (location?.coordinate.longitude)!,
                    "category": "飲食"
                ]
            
                Alamofire.request(.POST, "http://140.115.26.17:3000/api/record", parameters: data,headers: headers)
                    .responseJSON{
                        response in switch response.result {
                        case .Success(let JSON):
                            UIView.animateWithDuration(0.3, animations: {
                                self.alpha = 0
                                }, completion: { finished in
                                    self.removeFromSuperview()
                                    self.delegate!.recordFinish(self)
                            })
                            print (JSON)
                        case .Failure(let error):
                            print("Request failed with error: \(error)")
                        }
                }

                }) { (error) -> Void in
                    
                    print("1. Something went wrong -> \(error?.localizedDescription)")
            }
        } catch (let error) {
            print("Error \(error)")
        }

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
