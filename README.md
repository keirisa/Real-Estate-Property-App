# 🏡 Real Estate Property Finder App

![Swift](https://img.shields.io/badge/Swift-5.0-orange?style=for-the-badge&logo=swift)
![Xcode](https://img.shields.io/badge/Xcode-UIKit-blue?style=for-the-badge&logo=xcode)
![CoreData](https://img.shields.io/badge/Core%20Data-Local%20Storage-informational?style=for-the-badge)

An iOS application built using UIKit and Core Data that allows users to search for real estate listings via the Zillow API, save their favorite properties, and manage their account using local authentication.

---

## 📸 Screenshots

| Login/Register | Property Search | Favorites List |
|----------------|------------------|----------------|
| ![realestate_login](https://github.com/user-attachments/assets/ac2eacd8-23f3-44f6-9e58-3f7bc4a86879) | ![realestate_filter](https://github.com/user-attachments/assets/c97bc26e-c98a-4f06-9982-0f50a21ab0b7) | ![realestate_fav](https://github.com/user-attachments/assets/505a0a35-1f6e-4386-a034-d04b5d8d240b) |

---

## 📱 Features

- 🔐 **User Authentication**
  - Secure login and registration using Core Data
  - Session persistence across app relaunches

- 🔍 **Real-Time Property Search**
  - Integrated with [Zillow API](https://rapidapi.com/apimaker/api/zillow-com1)
  - Filter by 10+ parameters including price, beds, baths, property type, etc.
  - Listings displayed using `UITableView` or `UICollectionView`

- ⭐️ **Favorites Management**
  - Add/remove multiple properties to/from favorites
  - Sort by price or number of bedrooms
  - Address search for favorites
  - Favorites stored per logged-in user using Core Data

---

## 🧱 Tech Stack

- **Language**: Swift 5
- **Frameworks**: UIKit, CoreData
- **API**: Zillow (via RapidAPI)
- **Storage**: Core Data (User + Favorites)
- **Architecture**: MVC

---

## 🎬 Demo Video

▶️ [Watch on YouTube](#) *https://youtu.be/Hv4G8jSuSZM*

---

## 👤 Contributor

**Kate de Leon**  
[GitHub Profile](https://github.com/keirisa)
---
