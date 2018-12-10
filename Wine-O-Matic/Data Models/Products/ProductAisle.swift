//
//  ProductAisle.swift
//  Wine-O-Matic
//
//  Created by Mulloy, Charles on 12/4/18.
//  Copyright © 2018 Pat Mulloy. All rights reserved.
//

import Foundation

struct ProductAisle: Decodable {
    let title: String
    let groups: [ProductGroup]
}
