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

var itemField = UITextField()
var amountField = UITextField()
var mainView = UIScrollView()
var textButton = UIButton()
var currentStat = "text"
var recordButton = UIButton()

class RecordView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        let backgroundView = UIView(frame: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height))
        backgroundView.backgroundColor = UIColor.darkGrayColor()
        backgroundView.alpha = 0.8
        self.addSubview(backgroundView)
        
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
        
        textButton = UIButton()
        textButton.frame = CGRectMake( self.bounds.width/2 - 54, clearButton.frame.height + clearButton.frame.origin.y + 20, 44, 44)
        textButton.titleLabel!.font = UIFont.systemFontOfSize(44)
        textButton.setGMDIcon(GMDType.GMDTextFormat, forState: .Normal)
        textButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        textButton.addTarget(self, action: "showTextRecord:", forControlEvents: .TouchUpInside)
        self.addSubview(textButton)
        
        let qrCodeButton = UIButton()
        qrCodeButton.frame = CGRectMake( self.bounds.width/2 + 10, clearButton.frame.height + clearButton.frame.origin.y + 20, 44, 44)
        qrCodeButton.titleLabel!.font = UIFont.systemFontOfSize(44)
        qrCodeButton.setGMDIcon(GMDType.GMDCropFree, forState: .Normal)
        qrCodeButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        qrCodeButton.addTarget(self, action: "showCodeRecord:", forControlEvents: .TouchUpInside)
        self.addSubview(qrCodeButton)

        self.showTextRecord(textButton)
    }

    func showTextRecord(sender: UIButton) {
        mainView.removeFromSuperview()
        
        mainView = UIScrollView(frame: CGRectMake(0, textButton.frame.size.height + textButton.frame.origin.y + 10, self.frame.size.width, self.frame.size.height - (textButton.frame.size.height + textButton.frame.origin.y + 10) ))
        self.addSubview(mainView)
        
        let itemBorder = CALayer()
        let width = CGFloat(1.0)
        itemBorder.borderColor = UIColor(red: 55/255, green: 71/255, blue: 79/255, alpha: 1).CGColor
        itemBorder.frame = CGRect(x: 0, y: 44 - width, width:  self.frame.width - 60, height: 44)
        itemBorder.borderWidth = width
        
        itemField = UITextField(frame: CGRectMake(30, 10, self.frame.size.width - 60, 44))
        itemField.placeholder = "品項"
        itemField.layer.addSublayer(itemBorder)
        itemField.layer.masksToBounds = true
        itemField.attributedPlaceholder = NSAttributedString(string:"品項", attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        mainView.addSubview(itemField)
        
        let amountBorder = CALayer()
        amountBorder.borderColor = UIColor(red: 55/255, green: 71/255, blue: 79/255, alpha: 1).CGColor
        amountBorder.frame = CGRect(x: 0, y: 44 - width, width:  self.frame.width - 60, height: 44)
        amountBorder.borderWidth = width
        
        amountField = UITextField(frame: CGRectMake(30, itemField.frame.height + itemField.frame.origin.y + 10, self.frame.size.width - 60, 44))
        amountField.placeholder = "價錢"
        amountField.layer.addSublayer(amountBorder)
        amountField.layer.masksToBounds = true
        amountField.attributedPlaceholder = NSAttributedString(string:"價錢", attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        mainView.addSubview(amountField)
        
        recordButton = UIButton()
        recordButton.setTitle("紀錄", forState: .Normal)
        recordButton.sizeToFit()
        recordButton.frame = CGRectMake( 30, amountField.frame.height + amountField.frame.origin.y + 20, self.frame.size.width - 60, 40)
        recordButton.backgroundColor = UIColor(red: 214/255, green: 230/255, blue: 229/255, alpha: 1)
        recordButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        recordButton.addTarget(self, action: "recordData:", forControlEvents: .TouchUpInside)
        mainView.addSubview(recordButton)
        mainView.contentSize = CGSizeMake(self.frame.size.width,  recordButton.frame.size.height + recordButton.frame.origin.y)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let frame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        mainView = UIScrollView(frame: CGRectMake(0,
            textButton.frame.size.height + textButton.frame.origin.y + 10,
            self.frame.size.width,
            self.frame.size.height - (textButton.frame.size.height + textButton.frame.origin.y + 10) - frame.height
        ))
        mainView.contentSize = CGSizeMake(self.frame.size.width,  recordButton.frame.size.height + recordButton.frame.origin.y)
        
    }
    
    func showCodeRecord(sender: UIButton) {
        mainView.removeFromSuperview()
    }
    
    func cancelView(sender: UIButton) {
        self.removeFromSuperview()
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
