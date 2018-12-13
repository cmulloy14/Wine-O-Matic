//
//  ProductProvider.swift
//  Wine-O-Matic
//
//  Created by Mulloy, Charles on 12/5/18.
//  Copyright © 2018 Pat Mulloy. All rights reserved.
//

import UIKit

struct ProductProvider {

    private enum ProductProviderEndpoint: String {
        case getAisle = "https://api.foxtrotchicago.com/v5/inventory/aisles/224?groups=1"

        var url: URL? {
            return URL(string: self.rawValue)
        }
    }

    enum ProductProviderError: Error {
        case invalidURL
        case noData
        case failedJsonParsing
        case failedImageCreation

        var localizedDescription: String {
            switch self {
            case .invalidURL:
                return NSLocalizedString("Network error, please retry", comment: "")
            case .noData:
                return NSLocalizedString("Request returned no data, please retry", comment: "")
            case .failedJsonParsing:
                return NSLocalizedString("Could not parse data, please retry", comment: "")
            case .failedImageCreation:
                 return NSLocalizedString("Could not retreive image, please retry", comment: "")
            }
        }
    }


    // Perform a GET request for Foxtrot's Wine Aisle
    static func getAisle(fromLocal: Bool = false, completion: @escaping (ProductAisle?, Error?) -> Void) {

        if fromLocal {
            guard let fileURL = Bundle.main.url(forResource: "aisle", withExtension: "json"), let data = try? Data(contentsOf: fileURL) else {
                return
            }

            do {
                let aisle = try parseAisleData(data: data)
                completion(aisle, nil)
            }
            catch {
                completion(nil, error)
            }

            return
        }

        guard let url = ProductProviderEndpoint.getAisle.url else {
            completion(nil, ProductProviderError.invalidURL)
            return
        }

        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            guard error == nil else {
                completion(nil, error!)
                return
            }

            guard let data = data else {
                completion(nil, ProductProviderError.noData)
                return
            }

            do {
                let aisle = try parseAisleData(data: data)
                completion(aisle, nil)
            }

            catch {
                completion(nil, error)
            }
        }
        task.resume()

    }

    static func getImagesForAsset(_ asset: ProductAsset, completion: @escaping (UIImage?, Error?) -> Void) {
        guard let url = URL(string: asset.url) else {
            completion(nil, ProductProviderError.invalidURL)
            return
        }

        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            guard error == nil else {
                completion(nil, error!)
                return
            }

            guard let data = data else {
                completion(nil, ProductProviderError.noData)
                return
            }

            guard let image = UIImage(data: data) else {
                completion(nil, ProductProviderError.failedImageCreation)
                return
            }

            completion(image, nil)
        }

        task.resume()
    }

    static func parseAisleData(data: Data) throws -> ProductAisle {
        let aisleKey = "aisle"

        print(data.debugDescription)
        
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let aisleJson = json[aisleKey] as? [String: Any] else {
            throw ProductProviderError.failedJsonParsing
        }

        let aisleData = try JSONSerialization.data(withJSONObject: aisleJson, options: [])
        return try JSONDecoder().decode(ProductAisle.self, from: aisleData)
    }

}
