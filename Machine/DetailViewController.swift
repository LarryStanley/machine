//
//  DetailViewController.swift
//  Machine
//
//  Created by LarryStanley on 2015/12/1.
//  Copyright © 2015年 LarryStanley. All rights reserved.
//

import UIKit
import Timepiece
import ionicons
import KeychainSwift
import Alamofire
import MapKit

protocol DetailViewDelegate {
    func deleteFinish(ViewController: DetailViewController)
}

class DetailViewController: UIViewController {
    var itemData:NSDictionary = NSDictionary()
    var mainScrollView = UIScrollView()
    var transparentView = UIView()
    var delegate:DetailViewDelegate! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        let colorTop = UIColor(red: 66/255.0, green: 76/255.0, blue: 121/255.0, alpha: 1.0).CGColor
        let colorBottom = UIColor(red: 145/255.0, green: 133/255.0, blue: 161/255.0, alpha: 1.0).CGColor
        
        let gradient: CAGradientLayer
        gradient = CAGradientLayer()
        gradient.colors = [colorTop, colorBottom]
        gradient.startPoint = CGPointMake(0, 0)
        gradient.endPoint = CGPointMake(1, 1)
        gradient.locations = [0, 1]
        
        gradient.frame = self.view.bounds
        self.view.layer.insertSublayer(gradient, atIndex: 0)
        
        mainScrollView.frame = self.view.frame
        self.view.addSubview(mainScrollView)
        
        let amountLabel = UILabel()
        amountLabel.textColor = UIColor(hex: "ECEFF1")
        amountLabel.font  = UIFont(name: "HelveticaNeue-UltraLight", size: 90)
        amountLabel.text = "\(self.itemData["amount"] as! Int)"
        amountLabel.sizeToFit()
        amountLabel.center = self.view.center
        amountLabel.center.y = amountLabel.center.y - 50
        mainScrollView.addSubview(amountLabel)
        
        let unitLabel = UILabel()
        unitLabel.text = "NTD"
        unitLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 18)
        unitLabel.sizeToFit()
        unitLabel.textColor = UIColor.whiteColor()
        unitLabel.frame.origin.x = amountLabel.frame.size.width + amountLabel.frame.origin.x + 5
        unitLabel.frame.origin.y = amountLabel.frame.size.height + amountLabel.frame.origin.y - unitLabel.frame.size.height - 15
        mainScrollView.addSubview(unitLabel)
        
        let itemLabel = UILabel(frame: CGRectMake( 10, 10, 0, 0))
        itemLabel.textColor = UIColor(hex: "ECEFF1")
        itemLabel.text = (self.itemData["item"] as! String)
        itemLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 36)
        itemLabel.sizeToFit()
        mainScrollView.addSubview(itemLabel)
        
        var timeParser = (self.itemData["time"] as! String).dateFromFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ")
        let userTimeZone = NSTimeZone.localTimeZone()
        timeParser = timeParser?.change(timeZone: userTimeZone)
        
        let timeLabel = UILabel(frame: CGRectMake( 10, itemLabel.frame.size.height + itemLabel.frame.origin.y, 0, 0))
        timeLabel.textColor = UIColor(hex: "ECEFF1")
        timeLabel.text = timeParser?.stringFromFormat("HH:mm")
        timeLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 24)
        timeLabel.sizeToFit()
        mainScrollView.addSubview(timeLabel)
        
        transparentView = UIView(frame: CGRectMake(0, self.view.frame.origin.y + self.view.frame.height - 80 - self.navigationController!.navigationBar.frame.size.height, self.view.frame.width, 80))
        transparentView.backgroundColor = UIColor(hex: "263238")
        transparentView.alpha = 0.4
        mainScrollView.addSubview(transparentView)

        let textButton = UIButton()
        textButton.frame = CGRectMake( self.view.bounds.width/2 - 54, 5, 44, 44)
        textButton.titleLabel!.font = IonIcons.fontWithSize(40)
        textButton.setTitle(ion_ios_compose_outline, forState: .Normal)
        textButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        textButton.addTarget(self, action: #selector(DetailViewController.editTextRecord(_:)), forControlEvents: .TouchUpInside)
        transparentView.addSubview(textButton)
        
        let deleteButton = UIButton()
        deleteButton.frame = CGRectMake( self.view.bounds.width/2 + 10, 5, 44, 44)
        deleteButton.titleLabel!.font = IonIcons.fontWithSize(40)
        deleteButton.setTitle(ion_ios_trash_outline, forState: .Normal)
        deleteButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        deleteButton.addTarget(self, action: #selector(DetailViewController.deleteRecord(_:)), forControlEvents: .TouchUpInside)
        transparentView.addSubview(deleteButton)
        
        let lineBetweenDetailView = UIView(frame: CGRectMake( 20, deleteButton.frame.origin.y + deleteButton.frame.size.height + 15, self.view.bounds.width - 40, 1));
        lineBetweenDetailView.backgroundColor = UIColor(hex: "ECEFF1")
        transparentView.addSubview(lineBetweenDetailView)

        let mapView = MKMapView(frame: CGRectMake( 20, lineBetweenDetailView.frame.origin.y + lineBetweenDetailView.frame.size.height + 15 + transparentView.frame.origin.y, self.view.bounds.width - 40, 150))
        mapView.centerCoordinate = CLLocationCoordinate2DMake(self.itemData["location"]!["latitude"] as! Double, self.itemData["location"]!["longitude"] as! Double)
        mapView.region = MKCoordinateRegionMake(mapView.centerCoordinate, MKCoordinateSpanMake( 0.005 , 0.005))
        mainScrollView.addSubview(mapView)
        transparentView.frame = CGRectMake(transparentView.frame.origin.x, transparentView.frame.origin.y, transparentView.frame.size.width, mapView.frame.origin.y + mapView.frame.size.height + 10 + self.view.frame.height - transparentView.frame.origin.y)

        let mapPin = MKPointAnnotation()
        mapPin.title = (self.itemData["item"] as! String)
        mapPin.coordinate = mapView.centerCoordinate
        mapView.addAnnotation(mapPin)
        
        mainScrollView.contentSize = CGSizeMake(self.view.frame.size.width, transparentView.frame.origin.y + transparentView.frame.size.height - self.view.frame.height)
    }
    
    func editTextRecord(sender: UIButton) {
        let textRecordView = RecordView(frame: self.view.frame)
        textRecordView.alpha = 0;
        self.view.addSubview(textRecordView)
        UIView.animateWithDuration(0.3, animations: {
            textRecordView.alpha = 1
        })
    }
    
    func deleteRecord(sender: UIButton) {
        
        let data : [String: AnyObject] = [
            "id" : self.itemData["_id"]! as! String
        ]
        
        print(self.itemData["_id"]! as! String)
        
        let keychain = KeychainSwift()
        let headers = [
            "x-access-token": keychain.get("token")!
        ]
        
        
        Alamofire.request(.POST, "http://140.115.26.17:3000/api/delete", parameters: data,headers: headers)
            .responseJSON{
                response in switch response.result {
                case .Success(let JSON):
                    self.navigationController!.popViewControllerAnimated(true)
                    self.delegate!.deleteFinish(self)
                    print (JSON)
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.translucent = true
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        //self.view.backgroundColor = UIColor.clearColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
