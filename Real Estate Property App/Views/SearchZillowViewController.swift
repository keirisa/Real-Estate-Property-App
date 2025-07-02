//
//  SearchZillowViewController.swift
//  Real Estate Property App
//
//  Created by Kate Alyssa Joanna L. de Leon on 4/1/25.
//

import UIKit
import CoreData

class SearchZillowViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var filterStackView: UIStackView!
    
    // filter
    @IBOutlet weak var cityField: UITextField!
    @IBOutlet weak var stateField: UITextField!
    @IBOutlet weak var bedsField: UITextField!
    @IBOutlet weak var bathsField: UITextField!
    @IBOutlet weak var minPriceField: UITextField!
    @IBOutlet weak var maxPriceField: UITextField!
    @IBOutlet weak var propertyTypeField: UITextField!
    @IBOutlet weak var listingTypeField: UITextField!
    @IBOutlet weak var lotAreaField: UITextField!
    @IBOutlet weak var daysOnZillowField: UITextField!
    
    @IBOutlet weak var resultsTableView: UITableView!
    
    // MARK: - Properties
    var properties: [ZillowProperty] = []
    var filteredProperties: [ZillowProperty] = []
    var filters: [String: String] = [:]
    var loggedInUser: AppUser?
    private let propertyTypes = ["House", "Townhouse", "Single Family", "Multi Family", "Apartment"]
    private let listingTypes = ["FOR_SALE", "SOLD", "OTHER"]
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        resultsTableView.dataSource = self
        resultsTableView.delegate = self
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupScrollView()
        setupTypePickers()
        
        resultsTableView.register(PropertyTableViewCell.self, forCellReuseIdentifier: "PropertyCell")
        resultsTableView.rowHeight = UITableView.automaticDimension
        resultsTableView.estimatedRowHeight = 400
        resultsTableView.separatorStyle = .none

        //debug
        print("DEBUG: SearchVC instance: \(Unmanaged.passUnretained(self).toOpaque())")
        print("DEBUG: Received user: \(loggedInUser?.username ?? "nil")")
        
        // fallback if user wasn't passed
        if loggedInUser == nil {
            print("DEBUG: No user received, loading from Core Data")
            loadLastLoggedInUser()
        }
    }
    
    //DEBUG
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG: SearchVC viewWillAppear - User: \(loggedInUser?.username ?? "nil")")
        
        // fallback - try to load last logged in user if nil
        if loggedInUser == nil {
            loadLastLoggedInUser()
        }
    }
    
    private func loadLastLoggedInUser() {
        guard let username = UserDefaults.standard.string(forKey: "lastLoggedInUsername") else {
            print("DEBUG: No username stored in UserDefaults")
            return
        }
        
        let request: NSFetchRequest<AppUser> = AppUser.fetchRequest()
        request.predicate = NSPredicate(format: "username == %@", username)
        
        do {
            let users = try PersistenceController.shared.context.fetch(request)
            guard let user = users.first else {
                print("DEBUG: No user found with username \(username)")
                return
            }
            
            loggedInUser = user
            print("DEBUG: Successfully loaded specific user: \(user.username ?? "nil") (\(user.objectID))")
        } catch {
            print("DEBUG: Error loading specific user: \(error)")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        resultsTableView.reloadData()
        print("DEBUG: TableView frame: \(resultsTableView.frame)")
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    private func setupScrollView() {
        scrollView.delegate = self
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.decelerationRate = .fast
        
        contentView.removeConstraints(contentView.constraints)
        filterStackView.removeConstraints(filterStackView.constraints)
        
        let fieldCount = filterStackView.arrangedSubviews.count
        let fieldWidth: CGFloat = 120
        let spacing: CGFloat = 12
        let totalWidth = CGFloat(fieldCount) * fieldWidth + CGFloat(fieldCount - 1) * spacing
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor),
            contentView.widthAnchor.constraint(equalToConstant: totalWidth)
        ])
        
        filterStackView.axis = .horizontal
        filterStackView.distribution = .equalSpacing
        filterStackView.alignment = .center
        filterStackView.spacing = spacing
        filterStackView.translatesAutoresizingMaskIntoConstraints = false
        
        filterStackView.arrangedSubviews.forEach { view in
            view.widthAnchor.constraint(equalToConstant: fieldWidth).isActive = true
        }
        
        // update layout immediately
        view.layoutIfNeeded()
    }
    
    private func setupTypePickers() {
        let propertyTypePicker = UIPickerView()
        propertyTypePicker.delegate = self
        propertyTypePicker.dataSource = self
        propertyTypePicker.tag = 0
        propertyTypeField.inputView = propertyTypePicker
        
        let listingTypePicker = UIPickerView()
        listingTypePicker.delegate = self
        listingTypePicker.dataSource = self
        listingTypePicker.tag = 1
        listingTypeField.inputView = listingTypePicker
    }

    // MARK: - API Actions
    @IBAction func searchTapped(_ sender: UIButton) {
        guard validateFields() else { return }
        
        let filters: [String: String] = [
            "city": cityField.text?.trimmingCharacters(in: .whitespaces) ?? "",
            "state": stateField.text?.trimmingCharacters(in: .whitespaces) ?? "",
            "beds": bedsField.text ?? "",
            "baths": bathsField.text ?? "",
            "minPrice": minPriceField.text ?? "",
            "maxPrice": maxPriceField.text ?? "",
            "home_type": propertyTypeField.text ?? "",
            "listingStatus": listingTypeField.text ?? "",
            "lotArea": lotAreaField.text ?? "",
            "daysOnZillow": daysOnZillowField.text ?? ""
        ]
        
        searchZillow(with: filters)
    }

    private func searchZillow(with filters: [String: String]) {
        showLoadingIndicator()
        
        var components = URLComponents(string: "https://zillow-com1.p.rapidapi.com/propertyExtendedSearch")!
        var queryItems = [
            URLQueryItem(name: "location", value: "\(filters["city"] ?? ""), \(filters["state"] ?? "")"),
            URLQueryItem(name: "includes", value: "resoFacts")
        ]
        
        // filter parameters
        if let beds = filters["beds"], !beds.isEmpty {
            queryItems.append(URLQueryItem(name: "beds", value: beds))
        }
        if let baths = filters["baths"], !baths.isEmpty {
            queryItems.append(URLQueryItem(name: "baths", value: baths))
        }
        if let minPrice = filters["minPrice"], !minPrice.isEmpty {
            queryItems.append(URLQueryItem(name: "minPrice", value: minPrice))
        }
        if let maxPrice = filters["maxPrice"], !maxPrice.isEmpty {
            queryItems.append(URLQueryItem(name: "maxPrice", value: maxPrice))
        }
        if let homeType = filters["home_type"], !homeType.isEmpty {
            queryItems.append(URLQueryItem(name: "home_type", value: homeType))
        }
        if let lotArea = filters["lotArea"], !lotArea.isEmpty {
            queryItems.append(URLQueryItem(name: "lotArea", value: lotArea))
        }
        
        if let filterStatus = filters["listingStatus"], !filterStatus.isEmpty {
            print("DEBUG: Filtering for listingStatus: \(filterStatus)")
            filteredProperties = filteredProperties.filter { property in
                guard let propertyStatus = property.listingStatus else {
                    print("DEBUG: Property \(property.zpid) has no listingStatus")
                    return false
                }
                let matches = propertyStatus.lowercased() == filterStatus.lowercased()
                print("DEBUG: Comparing \(propertyStatus) vs \(filterStatus): \(matches)")
                return matches
            }
            print("DEBUG: After listingStatus filter: \(filteredProperties.count) properties")
        }
        
        components.queryItems = queryItems
        
        // DEBUG: Print the final URL
        print("DEBUG: API Request URL - \(components.url?.absoluteString ?? "invalid")")
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = [
            "x-rapidapi-key": "1298fb8878mshcb8be78b31448d6p1d5237jsn0fdd35ec0355",
            "x-rapidapi-host": "zillow-com1.p.rapidapi.com"
        ]
        
        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            DispatchQueue.main.async {
                self?.hideLoadingIndicator()
                
                guard let self = self else { return }
                if let error = error {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                    return
                }
                
                guard let data = data else {
                    self.showAlert(title: "Error", message: "No data received")
                    return
                }
                
                // print raw JSON for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("RAW API RESPONSE:\n\(String(jsonString.prefix(2000)))...")
                }
                
                do {
                    let decoder = JSONDecoder()
                    let decoded = try decoder.decode(ZillowSearchResponse.self, from: data)
                    self.properties = decoded.props
                
                    self.applyFilters(with: filters)
                    self.resultsTableView.reloadData()
                    
                } catch {
                    print("DEBUG: Decoding error - \(error)")
                    self.showAlert(title: "Error", message: "Failed to parse results")
                }
            }
        }.resume()
    }

    // MARK: - Filtering Logic
    private func applyFilters(with filters: [String: String]) {
        guard !properties.isEmpty else { return }
        
        filteredProperties = properties
        
        // Beds filter
        if let bedsText = filters["beds"], !bedsText.isEmpty,
           let beds = Double(bedsText) {
            filteredProperties = filteredProperties.filter {
                ($0.bedrooms ?? 0) >= beds
            }
            print("DEBUG: After beds filter - \(filteredProperties.count) properties")
        }
        
        // Baths filter
        if let bathsText = filters["baths"], !bathsText.isEmpty,
           let baths = Double(bathsText) {
            filteredProperties = filteredProperties.filter {
                Double($0.bathrooms ?? 0) >= baths
            }
            print("DEBUG: After baths filter - \(filteredProperties.count) properties")
        }
        
        // Price range
        if let minPriceText = filters["minPrice"], !minPriceText.isEmpty,
           let minPrice = Double(minPriceText) {
            filteredProperties = filteredProperties.filter {
                ($0.price ?? 0) >= minPrice
            }
        }
        
        if let maxPriceText = filters["maxPrice"], !maxPriceText.isEmpty,
           let maxPrice = Double(maxPriceText) {
            filteredProperties = filteredProperties.filter {
                ($0.price ?? 0) <= maxPrice
            }
        }
        
        // Parking filter
        if let lotAreaText = filters["lotArea"], !lotAreaText.isEmpty,
           let lotArea = Double(lotAreaText) {
            filteredProperties = filteredProperties.filter {
                guard let propLotArea = $0.lotAreaValue else { return false }
                return propLotArea >= lotArea && propLotArea != -1
            }
            print("DEBUG: After lot area filter - \(filteredProperties.count) properties")
        }
        
        if let daysText = filters["daysOnZillow"], !daysText.isEmpty,
            let days = Int(daysText) {
            filteredProperties = filteredProperties.filter {
                ($0.daysOnZillow ?? 0) <= days  // Shows properties listed in last X days
            }
        }
        
        // Property type
        if let type = filters["home_type"], !type.isEmpty {
            filteredProperties = filteredProperties.filter {
                ($0.propertyType ?? "").localizedCaseInsensitiveContains(type)
            }
        }
        
        // Listing type
        if let listingStatus = filters["listingStatus"], !listingStatus.isEmpty {
            filteredProperties = filteredProperties.filter {
                $0.listingStatus?.caseInsensitiveCompare(listingStatus) == .orderedSame
            }
        }
        
        properties = filteredProperties
        print("DEBUG: Final filtered count - \(properties.count) properties")
    }
    
    private func validateFields() -> Bool {
        // Safely unwrap the text fields
        guard let city = cityField.text, !city.isEmpty,
              let state = stateField.text, !state.isEmpty else {
            showAlert(title: "Missing Fields", message: "Please enter city and state")
            return false
        }
        
        // Validate price range
        if let minText = minPriceField.text, !minText.isEmpty,
           let maxText = maxPriceField.text, !maxText.isEmpty {
            guard let min = Int(minText), let max = Int(maxText) else {
                showAlert(title: "Invalid Input", message: "Price must be a number")
                return false
            }
            if min > max {
                showAlert(title: "Invalid Range", message: "Minimum price cannot exceed maximum price")
                return false
            }
        }
        
        // Validate numeric fields
        let numericFields = [
               (field: lotAreaField, name: "Lot Area"),
               (field: daysOnZillowField, name: "Days on Zillow")
           ]
        
        for field in numericFields {
            if let text = field.field?.text, !text.isEmpty {
                guard Int(text) != nil else {
                    showAlert(title: "Invalid Input", message: "\(field.name) must be a number")
                    return false
                }
            }
        }
        
        return true
    }
    
    // MARK: - TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return properties.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PropertyCell", for: indexPath) as? PropertyTableViewCell else {
            return UITableViewCell()
        }
        
        let property = properties[indexPath.row]
        let isFavorite = FavoritesManager.shared.isFavorite(property: property, for: self.loggedInUser)
        cell.configure(with: property, isFavorite: isFavorite)
        
        cell.favoriteButton.tag = indexPath.row
        cell.favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped(_:)), for: .touchUpInside)
        
        return cell
    }

    @objc private func favoriteButtonTapped(_ sender: UIButton) {
        print("DEBUG: Favorite tapped - Current user: \(loggedInUser?.username ?? "nil")")
        print("DEBUG: All properties: \(Thread.isMainThread ? "Main thread" : "Background thread")")
        guard let user = loggedInUser else {
                showAlert(title: "Error", message: "You need to be logged in to save favorites")
                
                // DEBUG why user is nil
                let fetchRequest: NSFetchRequest<AppUser> = AppUser.fetchRequest()
                do {
                    let users = try PersistenceController.shared.context.fetch(fetchRequest)
                    print("DEBUG: All users in DB: \(users.map { $0.username ?? "nil" })")
                } catch {
                    print("DEBUG: Error fetching users: \(error)")
                }
                
                return
            }
        
        let index = sender.tag
        guard index < properties.count else { return }
        
        let property = properties[index]
        
        if FavoritesManager.shared.isFavorite(property: property, for: user) {
            FavoritesManager.shared.removeFromFavorites(zpid: property.zpid, for: user)
            sender.isSelected = false
            showAlert(title: "Removed", message: "Property removed from favorites")
        } else {
            FavoritesManager.shared.addToFavorites(property: property, for: user)
            sender.isSelected = true
            showAlert(title: "Saved!", message: "Property added to favorites")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFavorites",
           let favoritesVC = segue.destination as? FavoritesViewController {
            favoritesVC.loggedInUser = self.loggedInUser
            print("DEBUG: Passing user \(self.loggedInUser?.username ?? "nil") to FavoritesVC")
        }
    }
    
    // MARK: - Helpers
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showLoadingIndicator() {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
    }
    
    private func hideLoadingIndicator() {
        navigationItem.rightBarButtonItem = nil
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let fieldWidth: CGFloat = 120
        let targetX = targetContentOffset.pointee.x
        let nearestIndex = round(targetX / fieldWidth)
        targetContentOffset.pointee.x = nearestIndex * fieldWidth
    }
}

// MARK: - Extensions
extension SearchZillowViewController: UIScrollViewDelegate {
    // scroll view delegate
}

extension UITextField {
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
}

extension SearchZillowViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView.tag == 0 ? propertyTypes.count : listingTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            return propertyTypes[row]
        } else {
            switch listingTypes[row] {
            case "FOR_SALE": return "FOR_SALE"
            case "SOLD": return "SOLD"
            case "OTHER": return "OTHER"
            default: return listingTypes[row]
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            propertyTypeField.text = propertyTypes[row]
        } else {
            listingTypeField.text = listingTypes[row]
        }
    }
}
