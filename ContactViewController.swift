//
//  ContactViewController.swift
//  MyContacts
//
//  Created by Admin on 08.03.2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

class ContactViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //MARK: Properties
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var datePickerTextField: UITextField!
    
    var contact: Contact?
    
    let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isToolbarHidden = false
        
        nameTextField.delegate = self
        phoneNumberTextField.delegate = self
        addressTextField.delegate = self
        datePickerTextField.delegate = self
        
        if let contact = contact{
            navigationItem.title = contact.name
            nameTextField.text = contact.name
            phoneNumberTextField.text = contact.phoneNumber
            photoImageView.image = contact.photo
            addressTextField.text = contact.address
            datePickerTextField.text = contact.dateOfBirth
        }
        updateSaveButtonState()
        createDatePicker()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        saveButton.isEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        updateSaveButtonState()
        navigationItem.title = nameTextField.text
    }
    
    //MARK: UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else{
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        photoImageView.image = selectedImage
        dismiss(animated: true, completion: nil)
    }

    
    // MARK: - Navigation

    @IBAction func cancel(_ sender: Any) {
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
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let button = sender as? UIBarButtonItem, button === saveButton else{
            return
        }
        let name = nameTextField.text ?? ""
        let phoneNumber = phoneNumberTextField.text ?? ""
        let photo = photoImageView.image
        let address = addressTextField.text ?? ""
        let dateOfBirth = datePickerTextField.text ?? ""
        contact = Contact(name: name, phoneNumber: phoneNumber, photo: photo, address: address, dateOfBirth: dateOfBirth)
    }
    
    //MARK: Actions
    
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        nameTextField.resignFirstResponder()
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    @IBAction func setAddress(sender: UIStoryboardSegue){
        if let sourceViewController = sender.source as? MapViewController, let address = sourceViewController.address{
            addressTextField.text = address
        }
    }
    //MARK: Private Methods
    
    private func updateSaveButtonState(){
        let nameText = nameTextField.text ?? ""
        let phoneNumberText = phoneNumberTextField.text ?? ""
        saveButton.isEnabled = !nameText.isEmpty && !phoneNumberText.isEmpty
        
    }
    
    private func createDatePicker(){
        datePicker.backgroundColor = UIColor.white
        datePicker.datePickerMode = .date
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(setDateOfBirth))
        toolbar.setItems([doneButton], animated: true)
        datePickerTextField.inputAccessoryView = toolbar
        datePickerTextField.inputView = datePicker
    }
    
    @objc private func setDateOfBirth(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        datePickerTextField.text = dateFormatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
}
