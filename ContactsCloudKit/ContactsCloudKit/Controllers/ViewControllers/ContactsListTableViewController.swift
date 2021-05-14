//
//  ContactsListTableViewController.swift
//  ContactsCloudKit
//
//  Created by James Lea on 5/14/21.
//

import UIKit

class ContactsListTableViewController: UITableViewController {

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAllContacts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAllContacts()
        
        tableView.reloadData()
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
        return ContactController.shared.contacts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath)
        
        let contact = ContactController.shared.contacts[indexPath.row]
        
        cell.textLabel?.text = contact.name
        cell.detailTextLabel?.text = contact.phone

        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toDetailVC" {
            if let index = tableView.indexPathForSelectedRow {
                guard let destination = segue.destination as? ContactsDetailViewController else {return}
                
                let contact = ContactController.shared.contacts[index.row]
                
                destination.contact = contact
            }
        }
    }
}//End of class
