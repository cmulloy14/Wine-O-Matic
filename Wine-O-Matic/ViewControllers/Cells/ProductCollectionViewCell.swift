//
//  ProductCollectionViewCell.swift
//  Wine-O-Matic
//
//  Created by Mulloy, Charles on 12/11/18.
//  Copyright © 2018 Pat Mulloy. All rights reserved.
//

import UIKit

class ProductCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func prepareForReuse() {
        imageView.image = nil
        titleLabel.text = nil
    }

}
