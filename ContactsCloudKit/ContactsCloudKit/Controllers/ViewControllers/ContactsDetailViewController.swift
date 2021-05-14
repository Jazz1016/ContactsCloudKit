//
//  ContactsDetailViewController.swift
//  ContactsCloudKit
//
//  Created by James Lea on 5/14/21.
//

import UIKit

class ContactsDetailViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneTextField.delegate = self
        
        updateViews()
    }
    
    // MARK: - Properties
    var contact: Contact?
    
    // MARK: - Actions
    
    @IBAction func saveButtonWasTapped(_ sender: Any) {
        saveContact()
    }
    
    
    // MARK: - Functions
    func saveContact(){
        guard let name = nameTextField.text, !name.isEmpty,
              let phone = phoneTextField.text, !phone.isEmpty,
              let email = emailTextField.text, !phone.isEmpty
               else {return}
        
        if contact != nil {
            guard let contact = contact else {return}
            contact.name = name
            contact.phone = phone
            contact.email = email
            ContactController.shared.editContact(contact: contact) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let contact):
                        print("\(contact.name) updated!")
                    case .failure(let error):
                        print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    }
                }
            }
        } else {
            ContactController.shared.createContact(name: name, phone: phone, email: email) { (result) in
                DispatchQueue.main.async {
                    switch result{
                    case .success(let string):
                        print(string)
                    case .failure(let error):
                        print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    }
                }
            }
        }
        navigationController?.popViewController(animated: true)
    }
    
    func updateViews() {
        guard let contact = contact else {return}
        
        self.nameTextField.text = contact.name
        self.phoneTextField.text = contact.phone
        self.emailTextField.text = contact.email
    }
}

extension ContactsDetailViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        let newString = (text as NSString).replacingCharacters(in: range, with: string)
        textField.text = format(with: "+X (XXX) XXX-XXXX", phone: newString)
        return false
    }
    
    func format(with mask: String, phone: String) -> String {
        let numbers = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = ""
        var index = numbers.startIndex // numbers iterator
        
        // iterate over the mask characters until the iterator of numbers ends
        for ch in mask where index < numbers.endIndex {
            if ch == "X" {
                // mask requires a number in this place, so take the next one
                result.append(numbers[index])
                
                // move numbers iterator to the next index
                index = numbers.index(after: index)
                
            } else {
                result.append(ch) // just append a mask character
            }
        }
        return result
    }
}
