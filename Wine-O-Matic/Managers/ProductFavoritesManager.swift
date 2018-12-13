//
//  ProductFavoritesManager.swift
//  Wine-O-Matic
//
//  Created by Mulloy, Charles on 12/8/18.
//  Copyright © 2018 Pat Mulloy. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let favoriteChanged = Notification.Name("favoriteChanged")
}

struct ProductFavoritesManager {

    enum FavoritesError: Error {
        case removeFailed
        case addFailed
    }

    private static let favoritesKey = "FavoriteProducts"
    //If the Live Scan is already added to Favorites, remove it. If its not a Favorite, add it to Favorites
    static func toggleFavorite(product: Product) throws {
        if favoritesContainsProduct(product) {
            if !removeFavorite(product: product) {
                throw FavoritesError.removeFailed
            }
        }
        else {
            if !addFavorite(product: product) {
                throw FavoritesError.addFailed
            }
        }
        NotificationCenter.default.post(name: .favoriteChanged, object: nil)
    }

    static func favoritesContainsProduct(_ product: Product) -> Bool {
        return favoriteIds.contains(product.id)
    }

    private static func removeFavorite(product: Product) -> Bool {
        let favorites = favoriteIds.filter { $0 != product.id }
        return saveFavoriteIds(favorites)
    }

    private static func addFavorite(product: Product) -> Bool {
        var favorites = favoriteIds
        favorites.append(product.id)
        return saveFavoriteIds(favorites)
    }

    private static func saveFavoriteIds(_ ids: [Int]) -> Bool {
        UserDefaults.standard.set(ids, forKey: favoritesKey)
        return UserDefaults.standard.synchronize()
    }

    static var favoriteIds: [Int] {
        guard let ids = UserDefaults.standard.value(forKey: favoritesKey) as? [Int] else {
            return []
        }
        return ids
    }

}
