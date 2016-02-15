//
//  QRCodeScannerView.swift
//  Machine
//
//  Created by LarryStanley on 2015/11/30.
//  Copyright © 2015年 LarryStanley. All rights reserved.
//

import UIKit
import AVFoundation
import ionicons
import KeychainSwift
import SwiftLocation
import Alamofire
import CoreLocation

protocol QRCodeViewDelegate {
    func CodeRecordFinish(view: QRCodeScannerView)
}

class QRCodeScannerView: UIView, AVCaptureMetadataOutputObjectsDelegate {
    
    var leftCode = false
    var rightCode = false
    var scanData = NSMutableArray()
    var captureSession = AVCaptureSession()
    var attentionLabel = UILabel()
    var delegate:QRCodeViewDelegate! = nil

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let backgroundView = UIView(frame: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height))
        backgroundView.backgroundColor = UIColor.darkGrayColor()
        backgroundView.alpha = 0.8
        self.addSubview(backgroundView)
        
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        let devices = AVCaptureDevice.devices().filter{ $0.hasMediaType(AVMediaTypeVideo) && $0.position == AVCaptureDevicePosition.Back }
        do {
            let input = try AVCaptureDeviceInput(device: devices.first as! AVCaptureDevice) as AVCaptureDeviceInput
            captureSession.addInput(input)
        } catch let error as NSError {
            print (error)
        }
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewLayer.frame = self.frame
        let view = UIView(frame: self.frame)
        view.layer.addSublayer(previewLayer)
        self.addSubview(view)
    
        let transparentView = UIView(frame: CGRectMake( 0, 0, self.frame.width, 80))
        transparentView.backgroundColor = UIColor.darkGrayColor()
        transparentView.alpha = 0.7
        self.addSubview(transparentView)
        
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
        
        attentionLabel.text = "請將發票至於螢幕中央"
        attentionLabel.textColor = UIColor(hex: "ECEFF1")
        attentionLabel.font  = UIFont(name: "HelveticaNeue-UltraLight", size: 16)
        attentionLabel.sizeToFit()
        attentionLabel.center = self.center
        attentionLabel.center.y = clearButton.center.y
        self.addSubview(attentionLabel)
        
        let outPut = AVCaptureMetadataOutput()
        captureSession.addOutput(outPut)
        outPut.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        outPut.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        captureSession.startRunning()
    }
    
    func cancelView(sender: UIButton) {
        captureSession.stopRunning()
        let currentCameraInput: AVCaptureInput = captureSession.inputs[0] as! AVCaptureInput
        let currentCameraOutput: AVCaptureOutput = captureSession.outputs[0] as! AVCaptureOutput
        captureSession.removeInput(currentCameraInput)
        captureSession.removeOutput(currentCameraOutput)
        UIView.animateWithDuration(0.3, animations: {
            self.alpha = 0
            }, completion: { finished in
                self.removeFromSuperview()
        })
    }

    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        if metadataObjects == nil || metadataObjects.count == 0 {
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        let items:NSMutableArray
        if metadataObj.type == AVMetadataObjectTypeQRCode {
            if metadataObj.stringValue != nil {
                let index: String.Index = metadataObj.stringValue.startIndex.advancedBy(2)
                if (metadataObj.stringValue.substringToIndex(index) == "**" && !rightCode) {
                    items = NSMutableArray(array: metadataObj.stringValue.componentsSeparatedByString(":"))
                    items.removeObjectAtIndex(0)
                    if (items.count%3 == 0) {
                        rightCode = true
                        scanData.addObjectsFromArray(items as [AnyObject])
                        attentionLabel.text = "請稍微靠左，掃描左方QR Code"
                        attentionLabel.sizeToFit()
                        attentionLabel.center.x = self.center.x
                    }
                } else if (!leftCode && metadataObj.stringValue.substringToIndex(index) != "**" ) {
                    items = NSMutableArray(array: metadataObj.stringValue.componentsSeparatedByString(":"))
                    if (items.count >= 4) {
                        for (var i = 0; i < 5; i++) {
                            items.removeObjectAtIndex(0)
                        }
                    }
                    
                    if (items.count%3 == 0) {
                        leftCode = true
                        scanData.addObjectsFromArray(items as [AnyObject])
                        attentionLabel.text = "請稍微靠右，掃描右方QR Code"
                        attentionLabel.sizeToFit()
                        attentionLabel.center.x = self.center.x
                    }
                }
            }
            
            if (leftCode && rightCode) {
                captureSession.stopRunning()
                let currentCameraInput: AVCaptureInput = captureSession.inputs[0] as! AVCaptureInput
                let currentCameraOutput: AVCaptureOutput = captureSession.outputs[0] as! AVCaptureOutput
                captureSession.removeInput(currentCameraInput)
                captureSession.removeOutput(currentCameraOutput)
                print(scanData)
                
                do {
                    try SwiftLocation.shared.currentLocation(Accuracy.Neighborhood, timeout: 60, onSuccess: { (location) -> Void in
                        
                        print("1. Location found \(location?.description)")
                        
                        let keychain = KeychainSwift()
                        let headers = [
                            "x-access-token": keychain.get("token")!
                        ]
                        
                        for (var i = 0; i < self.scanData.count; i = i + 3) {
                            let count:Int? = Int((self.scanData[i+1] as! String).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))
                            let amount:Int? = Int((self.scanData[i+2] as! String).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))
                            let data : [String: AnyObject] = [
                                "item": self.scanData[i],
                                "amount": count!*amount!,
                                "latitude": (location?.coordinate.latitude)!,
                                "longitude": (location?.coordinate.longitude)!,
                                "category": "飲食"
                            ]
                            
                            Alamofire.request(.POST, "http://140.115.26.17:3000/api/record", parameters: data, headers: headers)
                                .responseJSON{
                                    response in switch response.result {
                                    case .Success(let JSON):
                                        self.removeFromSuperview()
                                        print (JSON)
                                    case .Failure(let error):
                                        print("Request failed with error: \(error)")
                                    }
                            }
                        }
                        
                        }) { (error) -> Void in
                            
                            print("1. Something went wrong -> \(error?.localizedDescription)")
                            
                            let keychain = KeychainSwift()
                            let headers = [
                                "x-access-token": keychain.get("token")!
                            ]
                            
                            for (var i = 0; i < self.scanData.count; i = i + 3) {
                                let count:Int? = Int((self.scanData[i+1] as! String).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))
                                let amount:Int? = Int((self.scanData[i+2] as! String).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))
                                let data : [String: AnyObject] = [
                                    "item": self.scanData[i],
                                    "amount": count!*amount!,
                                    "latitude": "0.00",
                                    "longitude": "0.00",
                                    "category": "飲食"
                                ]
                                
                                Alamofire.request(.POST, "http://140.115.26.17:3000/api/record", parameters: data, headers: headers)
                                    .responseJSON{
                                        response in switch response.result {
                                        case .Success(let JSON):
                                            UIView.animateWithDuration(0.3, animations: {
                                                self.alpha = 0
                                                }, completion: { finished in
                                                    self.removeFromSuperview()
                                                    self.delegate!.CodeRecordFinish(self)
                                            })
                                            print (JSON)
                                        case .Failure(let error):
                                            print("Request failed with error: \(error)")
                                        }
                                }
                            }
                    }
                } catch (let error) {
                    print("Error \(error)")
                }
            
                self.removeFromSuperview()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}