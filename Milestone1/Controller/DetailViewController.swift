//
//  DetailViewController.swift
//  Milestone1
//
//  Created by Alistair Brice on 9/4/19.
//  Copyright © 2019 Alistair Brice. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class DetailViewController: UITableViewController, UITextFieldDelegate {
    ///This initalises the definition set by the class
    var copyOfOriginalItem: ObjectDefinition?
    ///This initalises the definition set by the class
    var detailItem: ObjectDefinition?

    
    ///This variables initialises the text fields
    @IBOutlet weak var nameField: UITextField!
    ///This variables initialises the text fields
    @IBOutlet weak var addressField: UITextField!
    ///This variables initialises the text fields
    @IBOutlet weak var latitudeField: UITextField!
    ///This variables initialises the text fields
    @IBOutlet weak var longitudeField: UITextField!
    ///This variables initialises the MKMap View
    @IBOutlet weak var mapView: MKMapView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        nameField.delegate = self
        addressField.delegate = self
        latitudeField.delegate = self
        longitudeField.delegate = self
    }
    
    ///This function will activate when the 'Cancel' button is pressed, deleting the table row being edited and replacing it with a copy of the original, and lastly reloads the table.
    @IBAction func cancelButton(_ sender: Any) {
        guard let copy = copyOfOriginalItem else { return }
        detailItem?.name = copy.name
        detailItem?.address = copy.address
        detailItem?.latitude = copy.latitude
        detailItem?.longitude = copy.longitude
        configureView()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "cancel"), object: nil)
    }
    
    ///This function grabs the coordinates of a location specified in the address field and applies the coordinates to the latitude and longitude fields
    func addressFinder(){
        let geo = CLGeocoder()
        guard let address = addressField.text else {
            return
        }
        if latitudeField.text == "0.0" && longitudeField.text == "0.0" || latitudeField.text == "" && longitudeField.text == ""{
            var latitude = ""
            var longitude = ""
            geo.geocodeAddressString(address){
                guard let placeMarks = $0 else{
                    print("Got Error: \(String(describing: $1))")
                    return
                }
                for placeMark in placeMarks{
                    guard let location = placeMark.location else{
                        continue
                    }
                
                    latitude = "\(location.coordinate.latitude)"
                    longitude = "\(location.coordinate.longitude)"
                    self.latitudeField.text = latitude
                    self.longitudeField.text = longitude
                    self.saveInModel()
                    self.mapLookUp()
                }
            }
        }
        
    }
    ///This function activates when the return button is pressed. It is responsible for saving changes to the table and searching map data
    func textFieldShouldReturn(_ sender: UITextField) -> Bool {
        self.view.endEditing(true)
        saveInModel()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
        if sender == addressField{
            addressFinder()
        }else if sender == latitudeField || sender == longitudeField{
            reverseGeoLookUp()
        }
        
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureView()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        saveInModel()
    }

    ///This fills the relevant data from the inputs if it exists. Then also prepares a copy in case of a cancel
    func configureView() {
        
        guard let detailItem = detailItem else {
            return
        }
        
        nameField.text = detailItem.name
        addressField.text = detailItem.address
        latitudeField.text = "\(detailItem.latitude)"
        longitudeField.text = "\(detailItem.longitude)"
        guard copyOfOriginalItem == nil else {
            return
        }
        
        if latitudeField.text != "" && latitudeField.text != "" && latitudeField.text != "0.0" && latitudeField.text != "0.0"{
            mapLookUp()
        }
        
        copyOfOriginalItem = ObjectDefinition(name: detailItem.name, address: detailItem.address, latitude: detailItem.latitude,longitude: detailItem.longitude )
    }

    ///This function saves the current inputs from the text fields as the default text for that specific cell
    func saveInModel() {
        if let nameStr = nameField{
            detailItem?.name = nameStr.text ?? ""
        }
        if let addressStr = addressField{
            detailItem?.address = addressStr.text ?? ""
        }
        if let latitudeStr = latitudeField?.text{
            if let latFinal = Double(latitudeStr){
                detailItem?.latitude = latFinal
            }
        }
        if let longitudeStr = longitudeField?.text{
            if let longFinal = Double(longitudeStr){
                detailItem?.longitude = longFinal
            }
        }
    }
    ///Takes the result of both the latitude and longitude text fields and and searches MapView of those coordinates, viewing from 10 kilometers above the location. A pin is also created at the coordinates with a title from the name text field and a subtitle from the coordinates.
    func mapLookUp(){
        let latNumConversion :Double? = Double(latitudeField.text!)
        let longNumConversion :Double? = Double(longitudeField.text!)
        let coordinates = CLLocationCoordinate2D(latitude: latNumConversion!, longitude: longNumConversion!)
        let region = MKCoordinateRegion(center: coordinates, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapView.setRegion(region, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            annotation.title = self.nameField.text
            annotation.subtitle = "\(coordinates.latitude), \(coordinates.longitude)"
            let annotationArray = self.mapView.annotations
            self.mapView.removeAnnotations(annotationArray)
            self.mapView.addAnnotation(annotation)
            
        }
    }
    
    ///This function searches for the data in the text fields and produces a string of the street address of the coordinates and applying it to the address field.
    func reverseGeoLookUp(){
        let geo = CLGeocoder()
        var numLat = 0.0
        var numLong = 0.0
        if let latSearch = latitudeField?.text {
            if let test = Double(latSearch){
                numLat = test
            }
        }
        if let longSearch = longitudeField?.text {
            if let test = Double(longSearch){
                numLong = test
            }
        }
        let location = CLLocation(latitude: numLat, longitude: numLong)
        geo.reverseGeocodeLocation(location) {
            guard let places = $0 else {
                print("Got error \(String(describing: $1))")
                return
            }
            for place in places {
                guard let name = place.name else {
                    print("Got no name")
                    continue
                }
                let add = "\(name), \(place.locality ?? ""), \(place.administrativeArea ?? "N/A"), \(place.country ?? "N/A"), \(place.postalCode ?? "N/A")"
                self.addressField.text = add
                self.mapLookUp()
                self.saveInModel()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "store"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
                
            }
        }
        
    }
    
}


