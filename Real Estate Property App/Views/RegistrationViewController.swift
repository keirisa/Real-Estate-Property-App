//
//  RegistrationViewController.swift
//  Real Estate Property App
//
//  Created by Kate Alyssa Joanna L. de Leon on 4/1/25.
//

import UIKit
import CoreData

class RegistrationViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    @IBAction func registerTapped(_ sender: UIButton) {
        guard let username = usernameField.text, !username.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            showAlert(title: "Missing Info", message: "Username and password are required.")
            return
        }

        let fetchRequest: NSFetchRequest<AppUser> = AppUser.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "username == %@", username)

        do {
            let existingUsers = try PersistenceController.shared.context.fetch(fetchRequest)
            if !existingUsers.isEmpty {
                showAlert(title: "Username Taken", message: "Please choose a different username.")
                return
            }
        } catch {
            print("Fetch error: \(error)")
            showAlert(title: "Error", message: "Try again later.")
            return
        }

        let newUser = AppUser(context: PersistenceController.shared.context)
        newUser.username = username
        newUser.password = password
        PersistenceController.shared.save()

        showAlert(title: "Registration Successful", message: "Please log in.")

    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
        present(alert, animated: true)
    }

}
