//
//  DetailViewController.swift
//  Milestone1
//
//  Created by Alistair Brice on 9/4/19.
//  Copyright © 2019 Alistair Brice. All rights reserved.
//

import UIKit
import CoreLocation

protocol DetailViewControllerDelegate: class {
    func insertNewObject()
    
}

class DetailViewController: UIViewController, UITextFieldDelegate {
    var detailItem: ObjectDefinition?
    weak var delegate: DetailViewControllerDelegate?
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var latitudeField: UITextField!
    @IBOutlet weak var longitudeField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        nameField.delegate = self
        addressField.delegate = self
        latitudeField.delegate = self
        longitudeField.delegate = self
    }
    
    func addressFinder(){
        let geo = CLGeocoder()
        guard let address = addressField.text else {
            return
        }
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
    func insertNewObject(_ sender: Any){
        guard let d = delegate else { return }
        d.insertNewObject()
    }
}


