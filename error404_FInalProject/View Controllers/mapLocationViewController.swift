//
//  mapLocationViewController.swift
//  error404_FInalProject
//
//  Created by Rizul goyal on 2020-01-23.
//  Copyright © 2020 Rizul goyal. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class mapLocationViewController: UIViewController {
    var lat:Double?
    var long:Double?
    
    enum transporttype : String
    {
        case automobile
        case walking
        
    }
    
    var transport = false
    
    
    @IBOutlet var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        
        
        // define lat and long
        
        let latitude: CLLocationDegrees = 43.64
        let longitude: CLLocationDegrees = -79.38
        
        // define delta lat and long
        
        let latDelta : CLLocationDegrees = 0.2
        let longDelta : CLLocationDegrees = 0.2
        //defione span
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
        
        // define location
        
        let location1 = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        // define the region
        
        let region = MKCoordinateRegion(center: location1, span: span)
        
        // set the region on the map
        mapView.setRegion(region, animated: true)
        
        
        navigationController?.navigationItem.largeTitleDisplayMode = .never
        let coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.showsUserLocation = true
        
        let location = CLLocation(latitude: lat!, longitude: long!)
        var address = ""
        
        CLGeocoder().reverseGeocodeLocation(location){(placemarks, error) in
            if let error = error
            {
                print(error)
            }
            else
            {
                if let placemark = placemarks?[0]{
                    if placemark.subAdministrativeArea != nil{
                        
                        
                        address = address + placemark.subAdministrativeArea! + " "
                    }
                    
                    
                    
                    if placemark.country != nil{
                        address = address + placemark.country! + " "
                    }
                    
                    
                    annotation.title = address
                    
                }
                
            }
            
        }
        mapView.addAnnotation(annotation)
        
        
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func navigateRoute(_ sender: UIButton) {
        
        
        let otherAlert = UIAlertController(title: "Transport Type", message: "Please choose one Transport Type.", preferredStyle: UIAlertController.Style.alert)
        
        
        
        let walkingbutton = UIAlertAction(title: "Walking", style: UIAlertAction.Style.default, handler: walkingHandler)
        
        let autobutton = UIAlertAction(title: "Automobile", style: UIAlertAction.Style.default, handler: autoHandler)
        
        
        
        
        // relate actions to controllers
        otherAlert.addAction(walkingbutton)
        otherAlert.addAction(autobutton)
        
        present(otherAlert, animated: true, completion: nil)
        
        
    }
    
    
    func findroute(route: transporttype)
    {
        
        let currentlocation = mapView.userLocation
        let currentlocationcoordinates = CLLocationCoordinate2D(latitude: currentlocation.coordinate.latitude, longitude: currentlocation.coordinate.longitude)
        let coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
        
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: currentlocationcoordinates, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary: nil))
        request.requestsAlternateRoutes = false
        
        if route.rawValue == "automobile"
        {
            request.transportType = .walking
            
        }
        else if route.rawValue == "walking"
        {
            request.transportType = .automobile
        }
        
        
        let directions = MKDirections(request: request)
        
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            
            let route = unwrappedResponse.routes[0]
            
            
            
            self.mapView.addOverlay(route.polyline)
            
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            
            
        }
        
        
    }
    
    
    
    func walkingHandler(alert: UIAlertAction){
        
        transport = true
        
        let currentlocation = mapView.userLocation
        let currentlocationcoordinates = CLLocationCoordinate2D(latitude: currentlocation.coordinate.latitude, longitude: currentlocation.coordinate.longitude)
        let destinationlocation = mapView.annotations
        let destinationlocationcoordinates = CLLocationCoordinate2D(latitude: destinationlocation[0].coordinate.latitude, longitude: destinationlocation[0].coordinate.longitude)
        print(String(currentlocationcoordinates.latitude) + " Longitude " + String(currentlocationcoordinates.longitude))
        print(String(destinationlocationcoordinates.latitude) + " Longitude " + String(destinationlocationcoordinates.longitude))
        
        let count = mapView.overlays.count
        if count != 0
        {
            mapView.removeOverlays(mapView.overlays)
        }
        
        findroute(route: .walking)
        
        
        // print("You tapped: \(alert.title)")
    }
    
    func autoHandler(alert: UIAlertAction){
        
        transport = false
        
        let currentlocation = mapView.userLocation
        let currentlocationcoordinates = CLLocationCoordinate2D(latitude: currentlocation.coordinate.latitude, longitude: currentlocation.coordinate.longitude)
        let destinationlocation = mapView.annotations
        let destinationlocationcoordinates = CLLocationCoordinate2D(latitude: destinationlocation[0].coordinate.latitude, longitude: destinationlocation[0].coordinate.longitude)
        print(String(currentlocationcoordinates.latitude) + " Longitude " + String(currentlocationcoordinates.longitude))
        print(String(destinationlocationcoordinates.latitude) + " Longitude " + String(destinationlocationcoordinates.longitude))
        
        let count = mapView.overlays.count
        if count != 0
        {
            mapView.removeOverlays(mapView.overlays)
        }
        
        findroute(route: .automobile)
    }
    
    
    
    
    
    
}

extension mapLocationViewController : MKMapViewDelegate
{
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        if transport == true
        {
            renderer.lineDashPattern = [0,10]
            renderer.strokeColor = UIColor.blue
        }
        else
        {
            renderer.strokeColor = UIColor.green
            
        }
        return renderer
    }
}










