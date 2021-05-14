//
//  Contact.swift
//  ContactsCloudKit
//
//  Created by James Lea on 5/14/21.
//

import Foundation
import CloudKit
import UIKit

class Contact {
    
    var name: String
    var phone: String?
    var email: String?
    var recordID: CKRecord.ID
    
    
    init(name: String, phone: String? = "", email: String? = "", recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)){
        self.name = name
        self.phone = phone
        self.email = email
        self.recordID = recordID
    }
}


extension Contact {
    convenience init?(ckRecord: CKRecord) {
        
        guard let name = ckRecord[ContactStrings.nameKey] as? String,
              let phone = ckRecord[ContactStrings.phoneKey] as? String,
              let email = ckRecord[ContactStrings.emailKey] as? String else {return nil}
        
        
        self.init(name: name, phone: phone, email: email, recordID: ckRecord.recordID)
    }
}

extension CKRecord {
    convenience init(contact: Contact) {
        
        self.init(recordType: ContactStrings.recordTypeKey, recordID: contact.recordID)
        
        self.setValuesForKeys([
        
            ContactStrings.nameKey : contact.name,
            ContactStrings.phoneKey : contact.phone!,
            ContactStrings.emailKey : contact.email!
            
        ])
        
    }
}


extension Contact: Equatable {
    static func == (lhs: Contact, rhs: Contact) -> Bool {
        return lhs.recordID == rhs.recordID
    }
    
}
