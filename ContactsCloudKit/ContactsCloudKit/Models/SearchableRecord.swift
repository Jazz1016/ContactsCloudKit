//
//  SearchableRecord.swift
//  ContactsCloudKit
//
//  Created by James Lea on 5/14/21.
//

import Foundation

protocol SearchableRecord {
    func matches(searchTerm: String) -> Bool
}
