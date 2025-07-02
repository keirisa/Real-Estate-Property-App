//
//  FavoritesViewController.swift
//  Real Estate Property App
//
//  Created by Kate Alyssa Joanna L. de Leon on 4/1/25.
//

import CoreData
import UIKit

class FavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var sortSegmentedControl: UISegmentedControl!
    
    var loggedInUser: AppUser? {
        didSet {
            // refresh favorites whenever the user changes
            refreshFavoritesForCurrentUser()
        }
    }
    var allFavorites: [FavoriteProperty] = []
    var filteredFavorites: [FavoriteProperty] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupSearchBar()
        setupSortControl()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 400
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // make sure u have correct user
        if loggedInUser == nil {
            loadCurrentUser()
        } else {
            refreshFavoritesForCurrentUser()
        }
    }
    
    private func setupTableView() {
        tableView.register(FavoriteCell.self, forCellReuseIdentifier: FavoriteCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundView = createEmptyStateLabel()
        tableView.backgroundView?.isHidden = true
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
    }
    
    private func setupSortControl() {
        sortSegmentedControl.removeAllSegments()
        sortSegmentedControl.insertSegment(withTitle: "Price", at: 0, animated: false)
        sortSegmentedControl.insertSegment(withTitle: "Rooms", at: 1, animated: false)
        sortSegmentedControl.insertSegment(withTitle: "Recent", at: 2, animated: false)
        sortSegmentedControl.selectedSegmentIndex = 0
    }
    
    private func createEmptyStateLabel() -> UILabel {
        let label = UILabel()
        label.text = "No favorites yet"
        label.textAlignment = .center
        label.textColor = .gray
        return label
    }
    
    private func loadCurrentUser() {
        guard let username = UserDefaults.standard.string(forKey: "lastLoggedInUsername") else {
            print("DEBUG: No username in UserDefaults")
            return
        }
        
        let request: NSFetchRequest<AppUser> = AppUser.fetchRequest()
        request.predicate = NSPredicate(format: "username == %@", username)
        
        do {
            let users = try PersistenceController.shared.context.fetch(request)
            if let user = users.first {
                self.loggedInUser = user
                print("DEBUG: Loaded user from Core Data: \(user.username ?? "nil")")
            } else {
                print("DEBUG: No user found with username: \(username)")
            }
        } catch {
            print("DEBUG: Error loading user: \(error)")
        }
    }
    
    func refreshFavoritesForCurrentUser() {
        guard let user = loggedInUser else {
            allFavorites = []
            filteredFavorites = []
            tableView.reloadData()
            tableView.backgroundView?.isHidden = false
            return
        }
        
        print("DEBUG: Refreshing favorites for user: \(user.username ?? "nil") (\(user.objectID))")
        
        let request: NSFetchRequest<FavoriteProperty> = FavoriteProperty.fetchRequest()
        request.predicate = NSPredicate(format: "appUser == %@", user)
        
        do {
            let results = try PersistenceController.shared.context.fetch(request)
            allFavorites = results
            filteredFavorites = results
            tableView.reloadData()
            tableView.backgroundView?.isHidden = !results.isEmpty
            print("DEBUG: Found \(results.count) favorites for \(user.username ?? "nil")")
            
            // Debug: Print all favorites with their associated users
            debugPrintCurrentUserFavorites()
        } catch {
            print("DEBUG: Error fetching favorites: \(error)")
        }
    }
    
    func debugPrintCurrentUserFavorites() {
        guard let user = loggedInUser else {
            print("DEBUG: No user logged in")
            return
        }
        
        let request: NSFetchRequest<FavoriteProperty> = FavoriteProperty.fetchRequest()
        request.predicate = NSPredicate(format: "appUser == %@", user)
        
        do {
            let favorites = try PersistenceController.shared.context.fetch(request)
            print("=== CURRENT USER FAVORITES ===")
            print("User: \(user.username ?? "nil") (\(user.objectID))")
            favorites.forEach {
                print("- \($0.address ?? "nil") (User: \($0.appUser?.username ?? "nil"))")
            }
        } catch {
            print("DEBUG: Error fetching favorites: \(error)")
        }
    }
    
    // MARK: - Actions
    @IBAction func sortChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            filteredFavorites.sort { $0.price < $1.price }
        case 1:
            filteredFavorites.sort { ($0.bedrooms, $0.bathrooms) < ($1.bedrooms, $1.bathrooms) }
        case 2:
            filteredFavorites.sort { $0.dateAdded ?? Date() > $1.dateAdded ?? Date() }
        default:
            break
        }
        tableView.reloadData()
    }
    
    @IBAction func logoutTapped(_ sender: UIButton) {
        // clear the current user
        loggedInUser = nil
        UserDefaults.standard.removeObject(forKey: "lastLoggedInUsername")
        
        if let loginVC = navigationController?.viewControllers.first(where: { $0 is LoginViewController }) {
            navigationController?.popToViewController(loginVC, animated: true)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
                navigationController?.setViewControllers([loginVC], animated: true)
            }
        }
    }
    
    // MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredFavorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteCell.reuseIdentifier, for: indexPath) as! FavoriteCell
        let favorite = filteredFavorites[indexPath.row]
        cell.configure(with: favorite)
        cell.delegate = self 
        return cell
    }
    
    // MARK: - Search Bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredFavorites = allFavorites
        } else {
            filteredFavorites = allFavorites.filter {
                $0.address?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
        tableView.reloadData()
    }
}

extension FavoritesViewController: FavoriteCellDelegate {
    func didTapRemoveButton(for property: FavoriteProperty) {
        // 1. Remove from Core Data
        FavoritesManager.shared.removeFromFavorites(zpid: property.zpid ?? "", for: loggedInUser)
        
        // 2. Update local data
        allFavorites.removeAll { $0.zpid == property.zpid }
        filteredFavorites.removeAll { $0.zpid == property.zpid }
        
        // 3. Update UI
        tableView.reloadData()
        
        // 4. Show empty state if needed
        tableView.backgroundView?.isHidden = !allFavorites.isEmpty
    }
}
