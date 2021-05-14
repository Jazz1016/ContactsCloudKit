//
//  ContactError.swift
//  ContactsCloudKit
//
//  Created by James Lea on 5/14/21.
//

import Foundation

enum ContactError: LocalizedError {
    case ckError(Error)
    case couldNotUnwrap
    case unexpectedRecordsFound
    
    var errorDescription: String? {
        switch self {
        case .ckError(let error):
            return "There was an error -- \(error) -- \(error.localizedDescription)."
        case .couldNotUnwrap:
            return "There was an error unwrapping the Contact."
        case .unexpectedRecordsFound:
            return "There were unexpected records found on CloudKit"
        }
    }
}
