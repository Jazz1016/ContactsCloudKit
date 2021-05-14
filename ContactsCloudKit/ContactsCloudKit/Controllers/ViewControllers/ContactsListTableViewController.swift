//
//  ContactsListTableViewController.swift
//  ContactsCloudKit
//
//  Created by James Lea on 5/14/21.
//

import UIKit

class ContactsListTableViewController: UITableViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var contactsSearchBar: UISearchBar!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        contactsSearchBar.delegate = self
        ContactController.shared.loadFromPersistentStore()
        fetchAllContacts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resultsArr = ContactController.shared.contacts
        tableView.reloadData()
    }
    
    // MARK: - Properties
    var resultsArr: [SearchableRecord] = []
    var isSearching: Bool = false
    var dataSource: [SearchableRecord] {
        
        
        
        if isSearching {
            return resultsArr
        } else {
            
            return ContactController.shared.contacts
        }
    }
    
    // MARK: - Functions
    func fetchAllContacts(){
        ContactController.shared.fetchAllContacts { result in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print(response)
                    self.tableView.reloadData()
                case .failure(let error):
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                }
            }
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath)
        
        let contact = dataSource[indexPath.row] as? Contact
        
        cell.textLabel?.text = contact?.name
        cell.detailTextLabel?.text = contact?.phone

        return cell
    }
    
//     Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let contactToDelete = dataSource[indexPath.row] as? Contact

            guard let index = ContactController.shared.contacts.firstIndex(of: contactToDelete!) else {return}


            ContactController.shared.deleteContact(contact: contactToDelete!) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let string):
                        ContactController.shared.contacts.remove(at: index)
                        ContactController.shared.saveToPersistentStore()
                        
                        
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        print(string)
                    case .failure(_):
                        print("error deleting contact")
                    }
                }
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toDetailVC" {
            if let index = tableView.indexPathForSelectedRow {
                guard let destination = segue.destination as? ContactsDetailViewController else {return}
                
                
                
                let contact = dataSource[index.row] as? Contact
                
                destination.contact = contact
            }
        }
    }
}//End of class

// MARK: - Extensions

extension ContactsListTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        resultsArr = ContactController.shared.contacts.filter(({ $0.matches(searchTerm: searchText.lowercased()) }))
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        resultsArr = ContactController.shared.contacts
        tableView.reloadData()
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearching = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        ContactController.shared.loadFromPersistentStore()
        fetchAllContacts()
        isSearching = false
    }
    
}
