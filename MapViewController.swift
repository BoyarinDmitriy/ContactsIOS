//
//  MapViewController.swift
//  MyContacts
//
//  Created by Admin on 09.03.2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {

    
    //MARK: Properties
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var searchTextField: UITextField!
    var address: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isToolbarHidden = false
        searchTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        getGeocode()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
   
    //MARK: Actions
    
    @IBAction func revealCoordinatesWithLongPressOnMap(_ sender: UILongPressGestureRecognizer) {
        //Determine the coordinates
        if sender.state != UIGestureRecognizerState.began{
            return
        }
        let touchLocation = sender.location(in: map)
        let locationCoordinate = map.convert(touchLocation, toCoordinateFrom: map)
        
        //Reverse coordinates to address
        getAddress(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude) { (placemark, error) in
            guard let placemark = placemark, error == nil else{
                return
            }
            
            //Create annotation with address title
            self.map.removeAnnotations(self.map.annotations)
            let annotation = MKPointAnnotation()
            annotation.coordinate = locationCoordinate
            annotation.title = "\(placemark.country ?? "") \(placemark.locality ?? "") \(placemark.thoroughfare ?? "") \(placemark.subThoroughfare ?? "")"
            self.map.addAnnotation(annotation)
            self.address = annotation.title
        }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        let isPressentingInAddContactMode = presentingViewController is UINavigationController
        
        if isPressentingInAddContactMode {
            dismiss(animated: true, completion: nil)
        }
        else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The ContactViewController is not inside a navigation controller.")
        }
    }
    
    
    
    //MARK: Geocode
    
    func getAddress(latitude: Double, longitude: Double, completion: @escaping (CLPlacemark?, Error?) -> ())  {
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude)) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                completion(nil, error)
                return
            }
            completion(placemark, nil)
        }
    }
    
    func getGeocode(){
        let address = searchTextField.text!
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location?.coordinate
                else {
                    let alert = UIAlertController()
                    alert.addAction(UIAlertAction(title: "Not found!", style: .default, handler: { (action) in }))
                    self.present(alert, animated: true, completion: nil)
                    return
            }
            let span : MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region : MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
            self.map.setRegion(region, animated: true)
        }
    }
    
    //MARK: Private Methods
}
