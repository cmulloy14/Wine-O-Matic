//
//  ProductGroup.swift
//  Wine-O-Matic
//
//  Created by Mulloy, Charles on 12/4/18.
//  Copyright © 2018 Pat Mulloy. All rights reserved.
//

import Foundation

struct ProductGroup: Decodable {

    let name: String
    var products: [Product]

    init(name: String, products: [Product]) {
        self.name = name
        self.products = products
    }
}

//Added Hashability for Set capabilities 
extension ProductGroup: Hashable {
    static func == (lhs: ProductGroup, rhs: ProductGroup) -> Bool {
        return lhs.name == rhs.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
}
