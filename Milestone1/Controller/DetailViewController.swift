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


protocol DetailViewControllerDelegate: class {
    func insertNewObject()
    func cancelPressed()
}

class DetailViewController: UITableViewController, UITextFieldDelegate {
    var copyOfOriginalItem: ObjectDefinition?
    var detailItem: ObjectDefinition?
    weak var delegate: DetailViewControllerDelegate?
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var latitudeField: UITextField!
    @IBOutlet weak var longitudeField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        nameField.delegate = self
        addressField.delegate = self
        latitudeField.delegate = self
        longitudeField.delegate = self
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        guard let copy = copyOfOriginalItem else { return }
        detailItem?.name = copy.name
        detailItem?.address = copy.address
        detailItem?.latitude = copy.latitude
        detailItem?.longitude = copy.longitude
        configureView()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "cancel"), object: nil)
    }
    
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        saveInModel()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
        delegate?.insertNewObject()
        addressFinder()
        
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureView()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        saveInModel()
    }

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
            // let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "")
            self.mapView.addAnnotation(annotation)
        }
    }
    
    func reverseGeoLookUp(){
        
    }
    
    func insertNewObject(_ sender: Any){
        guard let d = delegate else { return }
        d.insertNewObject()
    }
}


