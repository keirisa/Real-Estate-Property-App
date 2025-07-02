//
//  LoginViewController.swift
//  Real Estate Property App
//
//  Created by Kate Alyssa Joanna L. de Leon on 4/1/25.
//

import UIKit
import CoreData

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    var pendingUser: AppUser?  // used to pass on login success

    @IBAction func loginTapped(_ sender: UIButton) {
        guard let username = usernameField.text, !username.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            showAlert(title: "Missing Info", message: "Username and password are required.")
            return
        }

        let fetchRequest: NSFetchRequest<AppUser> = AppUser.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "username == %@ AND password == %@", username, password)

        do {
            let users = try PersistenceController.shared.context.fetch(fetchRequest)
            if let user = users.first {
                UserDefaults.standard.set(user.username, forKey: "lastLoggedInUsername")
                PersistenceController.shared.save()
                self.pendingUser = user
                print("DEBUG: Logging in user: \(user.username ?? "nil") (\(user.objectID))")
                self.performSegue(withIdentifier: "goToSearch", sender: user)
            } else {
                showAlert(title: "User Not Found", message: "Please register an account.") {
                    self.performSegue(withIdentifier: "goToRegister", sender: nil)
                }
            }
        } catch {
            print("Fetch error: \(error)")
            showAlert(title: "Error", message: "Something went wrong. Try again.")
        }
    }

    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in completion?() }))
        present(alert, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSearch",
           let destination = segue.destination as? SearchZillowViewController {
            
            // always use the pendingUser we set during login
            destination.loggedInUser = self.pendingUser
            
            print("DEBUG: Preparing segue - Passing user: \(self.pendingUser?.username ?? "nil")")
            print("DEBUG: Passing user objectID: \(self.pendingUser?.objectID.uriRepresentation() ?? URL(string: "nil")!)")
        }
        else if segue.identifier == "goToFavorites",
           let destination = segue.destination as? FavoritesViewController,
           let user = pendingUser {
            destination.loggedInUser = user
        }
    }
}
