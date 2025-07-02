//
//  FavoriteCell.swift
//  Real Estate Property App
//
//  Created by Kate Alyssa Joanna L. de Leon on 4/3/25.
//

import UIKit

protocol FavoriteCellDelegate: AnyObject {
    func didTapRemoveButton(for favorite: FavoriteProperty)
}

class FavoriteCell: UITableViewCell {
    static let reuseIdentifier = "FavoriteCell"
    
    weak var delegate: FavoriteCellDelegate?
    private var currentFavorite: FavoriteProperty?
    
    let propertyImageView = UIImageView()
    let detailsStackView = UIStackView()
    let addressLabel = UILabel()
    let priceLabel = UILabel()
    let specsLabel = UILabel()
    let removeButton = UIButton()
    
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
        addressLabel.text = nil
        priceLabel.text = nil
        specsLabel.text = nil
    }

    private func setupViews() {
        // full width fixed
        propertyImageView.contentMode = .scaleAspectFill
        propertyImageView.clipsToBounds = true
        propertyImageView.layer.cornerRadius = 0
        propertyImageView.backgroundColor = .systemGray6
        propertyImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(propertyImageView)
        
        // remove Button (over image)
        removeButton.setImage(UIImage(systemName: "trash"), for: .normal)
        removeButton.tintColor = .red
        removeButton.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        removeButton.layer.cornerRadius = 15
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        removeButton.addTarget(self, action: #selector(removeButtonTapped), for: .touchUpInside)
        contentView.addSubview(removeButton)
        
        //details stack view
        detailsStackView.axis = .vertical
        detailsStackView.spacing = 4
        detailsStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(detailsStackView)
        
        addressLabel.font = UIFont.boldSystemFont(ofSize: 18)
        addressLabel.numberOfLines = 2
        detailsStackView.addArrangedSubview(addressLabel)
        
        priceLabel.font = UIFont.boldSystemFont(ofSize: 16)
        priceLabel.textColor = .systemBlue
        detailsStackView.addArrangedSubview(priceLabel)
        
        specsLabel.font = UIFont.systemFont(ofSize: 14)
        specsLabel.textColor = .darkGray
        specsLabel.numberOfLines = 0
        detailsStackView.addArrangedSubview(specsLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // full width image
            propertyImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            propertyImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            propertyImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            propertyImageView.heightAnchor.constraint(equalTo: propertyImageView.widthAnchor, multiplier: 0.75),
            
            removeButton.topAnchor.constraint(equalTo: propertyImageView.topAnchor, constant: 12),
            removeButton.trailingAnchor.constraint(equalTo: propertyImageView.trailingAnchor, constant: -12),
            removeButton.widthAnchor.constraint(equalToConstant: 30),
            removeButton.heightAnchor.constraint(equalToConstant: 30),
            
            // details
            detailsStackView.topAnchor.constraint(equalTo: propertyImageView.bottomAnchor, constant: 12),
            detailsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            detailsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            detailsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with favorite: FavoriteProperty) {
        currentFavorite = favorite
        
        addressLabel.text = favorite.address ?? "Address not available"
        
        let priceFormatter = NumberFormatter()
        priceFormatter.numberStyle = .currency
        priceFormatter.maximumFractionDigits = 0
        priceLabel.text = priceFormatter.string(from: NSNumber(value: favorite.price)) ?? "Price N/A"
        
        let propertyType = favorite.propertyType ?? "N/A"
        let listingType = favorite.listingType ?? "N/A"
        
        var specsText = "\(favorite.bedrooms) bed | \(favorite.bathrooms) bath\n"
        specsText += "Type: \(propertyType) | Status: \(listingType)\n"
        
        if favorite.lotArea > 0 {
            let areaFormatter = NumberFormatter()
            areaFormatter.numberStyle = .decimal
            specsText += "Lot: \(areaFormatter.string(from: NSNumber(value: favorite.lotArea)) ?? "N/A") sqft"
        }
        
        specsLabel.text = specsText
        
        currentTask?.cancel()
        propertyImageView.image = UIImage(systemName: "photo.on.rectangle")
        
        if let imageUrl = favorite.imageURL, let url = URL(string: imageUrl) {
            currentTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let self = self else { return }
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        if self.addressLabel.text == favorite.address {
                            self.propertyImageView.image = image
                        }
                    }
                }
            }
            currentTask?.resume()
        }
    }
    
    @objc private func removeButtonTapped() {
        guard let favorite = currentFavorite else { return }
        delegate?.didTapRemoveButton(for: favorite)
    }
}
