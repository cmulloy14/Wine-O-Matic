//
//  ProductDetailViewController.swift
//  Wine-O-Matic
//
//  Created by Mulloy, Charles on 12/5/18.
//  Copyright © 2018 Pat Mulloy. All rights reserved.
//

import UIKit

class ProductDetailViewController: UIViewController {

    //MARK: - Instance Vars
    var product: Product!

    // MARK: - IBOutlets
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productDescriptionTextView: UITextView!

    @IBOutlet weak var blurbLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!

    @IBOutlet weak var noImageLabel: UILabel!
    @IBOutlet weak var imageActivityIndicator: UIActivityIndicatorView!

    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        
        title = product.title

        blurbLabel.text = product.blurb
        priceLabel.text = "$\(product.unitPrice)"
        productDescriptionTextView.text = product.description

        loadImage()
    }

    // MARK: - Loading methods
    private func loadImage() {
        guard let asset = product.assets.first else {
            noImageLabel.isHidden = false
            return
        }

        imageActivityIndicator.startAnimating()

        ProductProvider.getImagesForAsset(asset) { [weak self] (image, error) in
            DispatchQueue.main.async {
                self?.imageActivityIndicator.stopAnimating()
            }

            guard error == nil else {
                self?.showAlertForError(error!)
                return
            }

            guard let image = image else {
                self?.showAlertForError(ProductProvider.ProductProviderError.failedImageCreation)
                return
            }

            DispatchQueue.main.async {
                self?.noImageLabel.isHidden = true
                self?.productImageView.image = image
            }
        }
    }

    // MARK - Helper Methods
    private func handleImageError(_ error: Error) {
        noImageLabel.isHidden = false
        showAlertForError(error)
    }
}
