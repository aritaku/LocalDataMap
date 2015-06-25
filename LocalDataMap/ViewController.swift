//
//  ViewController.swift
//  LocalDataMap
//
//  Created by 有村 琢磨 on 2015/06/22.
//  Copyright (c) 2015年 有村 琢磨. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, NSURLConnectionDelegate{

    var myMapView :MKMapView!
    var myLocationManager :CLLocationManager!
    var userLocation: CLLocationCoordinate2D!
    var resortLocation: CLLocationCoordinate2D!
    
    var festivalLatitude: Double?
    var festivalLongitude: Double?
    
    var festivalName = [String]()
    
    
    //var koukyouArrays: Array! = [String]()
    //var koukyouDictionary: Dictionary! = [String:String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        festivalName = [String]()
        
        myMapView = MKMapView()
        myMapView.showsUserLocation = true
        myLocationManager = CLLocationManager()
        
        myMapView.delegate = self
        myLocationManager.delegate = self
        
        myLocationManager.distanceFilter = 100.0
        myLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        let status = CLLocationManager.authorizationStatus()
        if (status == CLAuthorizationStatus.NotDetermined){
            println("didChangeAuthorizationStatus:\(status)")
            self.myLocationManager.requestAlwaysAuthorization()
        }
        
        myMapView.frame = self.view.bounds
        self.view.addSubview(myMapView)
        myLocationManager.startUpdatingLocation()
        
        getData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //MARK: - 地図関連メソッド
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        println("regionDidChangeAnimated")
    }
    
    //現在地取得成功時
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        let location = locations.last as! CLLocation
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        //latitudeDelta, longitudeの値で現在地の表示領域を調整する
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 1.00, longitudeDelta: 1.00))
        self.myMapView.setRegion(region, animated: true)
        
        userLocation = CLLocationCoordinate2DMake(manager.location.coordinate.latitude, manager.location.coordinate.longitude)
        /*
        //現在地のアノテーション生成
        var userLocAnnotation: MKPointAnnotation = MKPointAnnotation()
        userLocAnnotration.coordinate = userLocation
        userLocAnnotation.title = "現在地"
        myMapView.addAnnotation(userLocAnnotation)
        */
    }
    
    //現在地取得失敗時
    func locationManager(manager: CLLocationManager!,didFailWithError error: NSError!){
        print("locationManager error")
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status{
        case .AuthorizedWhenInUse:
            println("AuthorizedWhenInUse")
        case .AuthorizedAlways:
            println("Authorized")
        case .Denied:
            println("Denied")
        case .Restricted:
            println("Restricted")
        case .NotDetermined:
            println("NotDetermined")
        default:
            println("etc.")
        }
    }
    
    // API取得の開始処理
    func getData() {
        var parameter : String! = "京都府"
        let searchWord:String! = parameter.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        let URL = NSURL(string: "https://www.chiikinogennki.soumu.go.jp/k-cloud-api/v001/kanko/%E8%A1%8C%E4%BA%8B%E3%83%BB%E7%A5%AD%E4%BA%8B/json?place=\(searchWord)")
        let req = NSURLRequest(URL: URL!)
        let connection: NSURLConnection = NSURLConnection(request: req, delegate: self, startImmediately: false)!
        
        // NSURLConnectionを使ってAPIを取得する
        NSURLConnection.sendAsynchronousRequest(req,
            queue: NSOperationQueue.mainQueue(),
            completionHandler: response)
    }
    
    // 取得したAPIデータの処理
    func response(res: NSURLResponse!, data: NSData!, error: NSError!){
        /*
        let json:NSDictionary = NSJSONSerialization.JSONObjectWithData(data,
            options: NSJSONReadingOptions.AllowFragments, error: nil) as! NSDictionary
        //let tourspots:NSDictionary = json.objectForKey("tourspots") as! NSDictionary
        let names:NSDictionary = json.objectForKey("[tourspots]") as! NSDictionary
        let name1:NSArray = names.objectForKey("name.written") as! NSArray
        */
        
        let json = JSON(data: data)
        if let name = json["tourspots"][0]["name"]["name1"]["written"].string{
            festivalName.append(name)
            println(name)
        }
        if var longitude : String = json["tourspots"][0]["place"]["coordinates"]["longitude"].string, var latitude : String = json["tourspots"][0]["place"]["coordinates"]["latitude"].string {
            festivalLatitude = atof(latitude)
            festivalLongitude = atof(longitude)
            println("経度\(longitude), 緯度\(latitude)")
        }
        
        makeTourspotsPins(festivalLatitude!,longitude: festivalLongitude!)

    }
    
    func makeTourspotsPins(latitude:Double, longitude:Double){
        
        var festivalPin :MKPointAnnotation = MKPointAnnotation()
        let pinLongitude :CLLocationDegrees = longitude
        let pinLatitude :CLLocationDegrees = latitude
        
        let coordinate :CLLocationCoordinate2D = CLLocationCoordinate2DMake(pinLatitude, pinLongitude)
        
        festivalPin.coordinate = coordinate
        festivalPin.title = festivalName[0]
        
        myMapView.addAnnotation(festivalPin)
        
    }

}

