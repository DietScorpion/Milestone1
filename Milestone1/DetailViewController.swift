//
//  DetailViewController.swift
//  Milestone1
//
//  Created by Alistair Brice on 9/4/19.
//  Copyright © 2019 Alistair Brice. All rights reserved.
//

import UIKit

protocol DetailViewControllerDelegate: class {
    func okayPressed()
    func cancelPressed()
    
}

class DetailViewController: UIViewController, UITextFieldDelegate {
    var detailItem: ObjectDefinition?
    var cancel = false
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
        /// This sets notifications for the keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    ///This tells the keyboard to disappear after pressing Return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    ///This Deinitializes the notifications for the keyboard location
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.okayPressed()
    }
    
    @objc func keyboardWillChange(notification: Notification) {
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        if UIDevice.current.orientation.isLandscape {
            if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillShowNotification {
                view.frame.origin.y = -keyboardRect.height + 100
            } else {
                view.frame.origin.y = 0
            }
        }
        
    }
    /** This function aims to configure the DetailView.
     This feeds the inputs from the the text fields into the array with the objects current Category.  */
    func configureView() {
        
        guard let detailItem = detailItem else {
            return
        }
        nameField.text = detailItem.name
        addressField.text = detailItem.address
        latitudeField.text = String(detailItem.latitude)
        longitudeField.text = String(detailItem.longitude)
    }

    func okayPressed(_ sender: Any) {
        guard let d = delegate else { return }
        d.okayPressed()
    }

}
