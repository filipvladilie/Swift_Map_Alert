//
//  ViewController.swift
//  HighWaters
//
//  Created by Vlad Filip on 08.01.2023.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

  @IBOutlet weak var mapView: MKMapView!
  private var locationManager: CLLocationManager!
  private var rootRef: DatabaseReference!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.rootRef = Database.database().reference()
    
    self.locationManager = CLLocationManager()
    self.locationManager.delegate = self
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    self.locationManager.distanceFilter = kCLDistanceFilterNone
    
    self.mapView.showsUserLocation = true
    self.mapView.delegate = self
    
    self.locationManager.requestWhenInUseAuthorization()
    self.locationManager.startUpdatingLocation()
    
    setupUI()
    
    populateFloodedRegions()
  }
  
  private func populateFloodedRegions() {
    let floodedRegionsRef = self.rootRef.child("flooded-regions")
    floodedRegionsRef.observe(.value) { snapshot in
      self.mapView.removeAnnotations(self.mapView.annotations)
      for child in snapshot.children {
        let snap = child as! DataSnapshot
        let dict = snap.value as! [String: Any]
        let latitude = dict["latitude"] as! Double
        let longitude = dict["longitude"] as! Double
        
        DispatchQueue.main.async {
          let annotation = MKPointAnnotation()
          annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
          self.mapView.addAnnotation(annotation)
        }
      }
    }
  }
  
  private func setupUI() {
    let addFloodButton = UIButton(frame: CGRect.zero)
    addFloodButton.setImage(UIImage(systemName: "person.wave.2.fill"), for: .normal)
    addFloodButton.addTarget(self, action: #selector(addFloodAnnotation), for: .touchUpInside)
    addFloodButton.translatesAutoresizingMaskIntoConstraints = false
    self.view.addSubview(addFloodButton)
    addFloodButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    addFloodButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -40).isActive = true
    addFloodButton.widthAnchor.constraint(equalToConstant: 75).isActive = true
    addFloodButton.heightAnchor.constraint(equalToConstant: 75).isActive = true
  }
  
  @objc func addFloodAnnotation(sender: Any?){
    if let location = self.locationManager.location {
      let floodAnnotation = MKPointAnnotation()
      floodAnnotation.coordinate = location.coordinate
      self.mapView.addAnnotation(floodAnnotation)
      let flood = Flood(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    
      let floodedRegionsref = self.rootRef.child("flooded-regions")
      let floodRef = floodedRegionsref.childByAutoId()
      floodRef.setValue(flood.toDictionary())
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    if let location = locations.first {
      let coordinate = location.coordinate
      self.mapView.camera.centerCoordinate = coordinate
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

}
