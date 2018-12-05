//
//  ProductDetailViewController.swift
//  Wine-O-Matic
//
//  Created by Mulloy, Charles on 12/5/18.
//  Copyright © 2018 Pat Mulloy. All rights reserved.
//

import UIKit

class ProductDetailViewController: UIViewController {

    var product: Product!

    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productDescriptionTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = product.title
        productDescriptionTextView.text = product.description

        guard let asset = product.assets.first else {
            return
        }

        ProductProvider.getImagesForAsset(asset) { (image, error) in
            guard error == nil else {
                print(error!)
                return
            }

            guard let image = image else {
                // TODO: Handle Error
                print("No image")
                return
            }

            DispatchQueue.main.async {
                self.productImageView.image = image
            }
        }
    }
}
