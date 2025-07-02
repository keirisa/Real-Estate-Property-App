//
//  PropertyTableViewCell.swift
//  Real Estate Property App
//
//  Created by Kate Alyssa Joanna L. de Leon on 4/2/25.
//

import UIKit

class PropertyTableViewCell: UITableViewCell {
    // ui components
    let propertyImageView = UIImageView()
    let detailsStackView = UIStackView()
    let addressLabel = UILabel()
    let priceLabel = UILabel()
    let specsLabel = UILabel()
    let favoriteButton = UIButton()
    
    private var currentTask: URLSessionDataTask?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupConstraints()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        currentTask?.cancel()
        propertyImageView.image = nil
    }
    
    private func setupViews() {
        // img view (full width)
        propertyImageView.contentMode = .scaleAspectFill
        propertyImageView.clipsToBounds = true
        propertyImageView.layer.cornerRadius = 0
        propertyImageView.backgroundColor = .systemGray6
        propertyImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(propertyImageView)
        
        // favorite button (over image)
        favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        favoriteButton.tintColor = .red
        favoriteButton.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        favoriteButton.layer.cornerRadius = 15
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(favoriteButton)
        
        // details stack view
        detailsStackView.axis = .vertical
        detailsStackView.spacing = 4
        detailsStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(detailsStackView)
        
        addressLabel.font = UIFont.boldSystemFont(ofSize: 18)
        addressLabel.numberOfLines = 2
        detailsStackView.addArrangedSubview(addressLabel)
        
        priceLabel.font = UIFont.boldSystemFont(ofSize: 16)
        detailsStackView.addArrangedSubview(priceLabel)
        
        specsLabel.font = UIFont.systemFont(ofSize: 14)
        specsLabel.textColor = .darkGray
        specsLabel.numberOfLines = 0
        detailsStackView.addArrangedSubview(specsLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([

            propertyImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            propertyImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            propertyImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            propertyImageView.heightAnchor.constraint(equalTo: propertyImageView.widthAnchor, multiplier: 0.75),
            

            favoriteButton.topAnchor.constraint(equalTo: propertyImageView.topAnchor, constant: 12),
            favoriteButton.trailingAnchor.constraint(equalTo: propertyImageView.trailingAnchor, constant: -12),
            favoriteButton.widthAnchor.constraint(equalToConstant: 30),
            favoriteButton.heightAnchor.constraint(equalToConstant: 30),
            

            detailsStackView.topAnchor.constraint(equalTo: propertyImageView.bottomAnchor, constant: 12),
            detailsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            detailsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            detailsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with property: ZillowProperty, isFavorite: Bool = false) {
        addressLabel.text = property.address ?? "Address not available"
        
        let priceFormatter = NumberFormatter()
        priceFormatter.numberStyle = .currency
        priceFormatter.maximumFractionDigits = 0
        priceLabel.text = property.price != nil ? priceFormatter.string(from: NSNumber(value: property.price!)) ?? "Price N/A" : "Price N/A"
        
        let beds = property.bedrooms ?? 0
        let baths = property.bathrooms ?? 0
        let propertyType = property.propertyType?.replacingOccurrences(of: "_", with: " ").capitalized ?? "N/A"
        let listingStatus = property.listingStatus?.replacingOccurrences(of: "_", with: " ").capitalized ?? "N/A"
        
        var specsText = "\(beds) bed | \(String(format: "%.1f", baths)) bath\n"
        specsText += "Type: \(propertyType) | Status: \(listingStatus)\n"
        
        if let lotArea = property.lotAreaValue, lotArea > 0 {
            let areaFormatter = NumberFormatter()
            areaFormatter.numberStyle = .decimal
            specsText += "Lot: \(areaFormatter.string(from: NSNumber(value: lotArea)) ?? "N/A") sqft | "
        }
        
        if let days = property.daysOnZillow, days > 0 {
            specsText += "Listed: \(days) day\(days == 1 ? "" : "s") ago"
        }
        
        specsLabel.text = specsText
        
        favoriteButton.isSelected = isFavorite
        
        loadPropertyImage(from: property.imgSrc)
    }
    
    private func loadPropertyImage(from urlString: String?) {
        currentTask?.cancel()
        propertyImageView.image = UIImage(systemName: "photo.on.rectangle")
        
        guard let urlString = urlString, let url = URL(string: urlString) else { return }
        
        currentTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self else { return }
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.propertyImageView.image = image
                }
            }
        }
        currentTask?.resume()
    }
}
