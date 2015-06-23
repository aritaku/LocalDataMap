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

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    var myMapView :MKMapView!
    var myLocationManager :CLLocationManager!
    var userLocation: CLLocationCoordinate2D!
    var resortLocation: CLLocationCoordinate2D!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myMapView = MKMapView()
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
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
        
        //現在地のアノテーション生成
        var userLocAnnotation: MKPointAnnotation = MKPointAnnotation()
        userLocAnnotation.coordinate = userLocation
        userLocAnnotation.title = "現在地"
        myMapView.addAnnotation(userLocAnnotation)
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
}

