//
//  ContactController.swift
//  ContactsCloudKit
//
//  Created by James Lea on 5/14/21.
//

import Foundation
import CloudKit

class ContactController {
    
    static let shared = ContactController()
    
    var contacts: [Contact] = []
    
    let privateDB = CKContainer.default().privateCloudDatabase
    
    func createContact (name: String, phone: String, email: String, completion: @escaping (Result<String, ContactError>) -> Void){
        
        let newContact = Contact(name: name, phone: phone, email: email)
        
        let record = CKRecord(contact: newContact)
        
        privateDB.save(record) { record, error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.ckError(error)))
            }
            
            guard let record = record else { return completion(.failure(.couldNotUnwrap))}
            
            guard let savedContact = Contact(ckRecord: record) else {return completion(.failure(.couldNotUnwrap))}
            
            self.contacts.insert(savedContact, at: 0)
            
            completion(.success("Contact successfully created"))
        }
    }
    
    func fetchAllContacts(completion: @escaping (Result<String, ContactError>) -> Void){
        
        
        
        let fetchAllPredicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: ContactStrings.recordTypeKey, predicate: fetchAllPredicate)
        
        privateDB.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.ckError(error)))
            }
            
            guard let records = records else {return completion(.failure(.couldNotUnwrap))}
            
            let fetchedContacts = records.compactMap({ Contact(ckRecord: $0) })
            
            self.contacts = fetchedContacts
            
            
            
            completion(.success("Successfully fetched Contacts!"))
        }
    }
    
    func editContact (contact: Contact, completion: @escaping (Result<Contact, ContactError>) -> Void){
        
        
        
        let record = CKRecord(contact: contact)
        
        let updateOperation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        
        updateOperation.savePolicy = .changedKeys
        
        updateOperation.qualityOfService = .userInteractive
        
        updateOperation.modifyRecordsCompletionBlock = { records, _, error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.ckError(error)))
            }
            
            guard let record = records?.first else {return completion(.failure(.couldNotUnwrap))}
            
            
            
            
            guard let updatedContact = Contact(ckRecord: record) else {return completion(.failure(.couldNotUnwrap))}
            
            
            
            
            completion(.success(updatedContact))
        }
        privateDB.add(updateOperation)
    }
    
    func deleteContact (contact: Contact, completion: @escaping (Result<String, ContactError>) -> Void){
        
        let deleteOperation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [contact.recordID])
        
        deleteOperation.savePolicy = .changedKeys
        
        deleteOperation.qualityOfService = .userInteractive
        
        deleteOperation.modifyRecordsCompletionBlock = { records, _, error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.ckError(error)))
            }
            
            if records?.count == 0 {
                completion(.success("Deleted record from Cloudkit"))
            } else {
                return completion(.failure(.unexpectedRecordsFound))
            }
        }
        privateDB.add(deleteOperation)
    }
    
//     MARK: - Persistence
//    func createPersistentStore() -> URL {
//        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        let fileURL = url[0].appendingPathComponent("ContactsCloudKit.json")
//        return fileURL
//    }
//
//    func saveToPersistentStore() {
//        do {
//            let data = try JSONEncoder().encode(contacts)
//            try data.write(to: createPersistentStore())
//        } catch {
//            print("ERROR ENCODING SONGS")
//        }
//    }
//
//    func loadFromPersistentStore() {
//        do {
//            let data = try Data(contentsOf: createPersistentStore())
//            contacts = try JSONDecoder().decode([Contact].self, from: data)
//        } catch {
//            print("ERROR LOADING SONGS")
//        }
//    }
}
