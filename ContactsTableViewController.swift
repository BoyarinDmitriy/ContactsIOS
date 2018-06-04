//
//  ContactsTableViewController.swift
//  MyContacts
//
//  Created by Admin on 08.03.2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

class ContactsTableViewController: UITableViewController {

    //MARK: Properties
    
    var contacts = [Contact]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = editButtonItem
        
        navigationController?.isToolbarHidden = false
        
        var savedContacts = loadContacts()
        savedContacts = sort(contacts: savedContacts)
        contacts += savedContacts!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return contacts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "ContactTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ContactTableViewCell else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        
        let contact = contacts[indexPath.row]
        
        cell.nameLabel.text = contact.name
        cell.phoneNumberLabel.text = contact.phoneNumber
        cell.photoImageView.image = contact.photo

        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            contacts.remove(at: indexPath.row)
            saveContacts()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "ShowDetails"{
            guard let contactDetailViewController = segue.destination as? ContactViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedContactCell = sender as? ContactTableViewCell else{
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedContactCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedContact = contacts[indexPath.row]
            contactDetailViewController.contact = selectedContact
        }
    }
    
    //MARK: Actions
    
    @IBAction func unwindToContactList(sender: UIStoryboardSegue) {
            if let sourceViewController = sender.source as? ContactViewController, let contact = sourceViewController.contact {
                
                if let selectedIndexPath = tableView.indexPathForSelectedRow {
                    // Update an existing contact.
                    contacts[selectedIndexPath.row] = contact
                    tableView.reloadRows(at: [selectedIndexPath], with: .none)
                }
                else {
                    // Add a new contact.
                    let newIndexPath = IndexPath(row: contacts.count, section: 0)
                    
                    contacts.append(contact)
                    tableView.insertRows(at: [newIndexPath], with: .automatic)
                }
                saveContacts()
            }
        
        contacts.removeAll()
        var savedContacts = loadContacts()
        savedContacts = sort(contacts: savedContacts)
        contacts += savedContacts!
        
        tableView.reloadData()
    }

    //MARK: Private Methods
  
    private func saveContacts() {
       NSKeyedArchiver.archiveRootObject(contacts, toFile: Contact.ArchiveURL.path)
    }
    
    private func loadContacts() -> [Contact]?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Contact.ArchiveURL.path) as? [Contact]
    }
    
    private func sort(contacts: [Contact]?) -> [Contact]?{
        return contacts?.sorted(by: {$0.name < $1.name})
    }
}
