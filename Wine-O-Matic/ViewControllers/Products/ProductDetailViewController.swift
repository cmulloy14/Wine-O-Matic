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
    var cart: ProductGroup! {
        didSet {
            cartDelegate?.updateCart(cart)
            cartView?.number = cart.products.count
        }
    }
    weak var cartDelegate: CartUpdatable?

    var cartView: CartView? {
        return navigationItem.rightBarButtonItem?.customView as? CartView
    }

    // MARK: - IBOutlets
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productDescriptionTextView: UITextView!

    @IBOutlet weak var blurbLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!

    @IBOutlet weak var noImageLabel: UILabel!
    @IBOutlet weak var imageActivityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var favoritesButton: UIButton!
    @IBOutlet weak var cartButton: UIButton!

    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = product.title

        blurbLabel.text = product.blurb
        priceLabel.text = "$\(product.unitPrice)"
        productDescriptionTextView.text = product.description

        configureFavoriteButton()
        configureCartButton()
        
        NotificationCenter.default.addObserver(self, selector: #selector(favoriteChanged), name: .favoriteChanged, object: nil)

        let cartView = CartView.initFromXib(with: cart.products.count)
        cartView.delegate = self

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: cartView)
        
        loadImage()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cartVC = segue.destination as? ProductCartTableViewController else {
            return
        }
        cartVC.cart = cart
    }

    @objc func favoriteChanged() {
        configureFavoriteButton()
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

    @IBAction func toggleFavorite(_ sender: Any) {
        do {
            try ProductFavoritesManager.toggleFavorite(product: product)
        }
        catch {
            showAlertForError(error)
        }
    }

    @IBAction func toggleCart(_ sender: Any) {
        if cart.products.contains(product) {
            cart.products.removeAll { $0 == product }
        } else {
            cart.products.append(product)
        }
        configureCartButton()
    }

    // MARK - Helper Methods
    private func handleImageError(_ error: Error) {
        noImageLabel.isHidden = false
        showAlertForError(error)
    }

    private func configureCartButton() {
        DispatchQueue.main.async {
            let title = self.cart.products.contains(self.product) ? NSLocalizedString("Remove from Cart", comment: "") : NSLocalizedString("Add to Cart", comment: "")
            self.cartButton.setTitle(title, for: .normal)
        }
    }

    private func configureFavoriteButton() {
        DispatchQueue.main.async {
            let text = ProductFavoritesManager.favoritesContainsProduct(self.product) ? NSLocalizedString("Remove from Favorites", comment: "") : NSLocalizedString("Add to Favorites", comment: "")
            self.favoritesButton.setTitle(text, for: .normal)
        }

    }
}

extension ProductDetailViewController: CartSelectable {
    func showCart() {
        performSegue(withIdentifier: "showCart", sender: nil)
    }
}
