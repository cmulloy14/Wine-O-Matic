//
//  ProductAisleViewController.swift
//  Wine-O-Matic
//
//  Created by Mulloy, Charles on 12/5/18.
//  Copyright © 2018 Pat Mulloy. All rights reserved.
//

import UIKit

class ProductAisleViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var wineTypeSelectionButton: UIButton!
    @IBOutlet weak var aisleLoadingIndicator: UIActivityIndicatorView!

    @IBOutlet weak var selectedTypeView: UIView!
    @IBOutlet weak var selectionCollectionView: UICollectionView!

    //MARK: - Instance Variables
    var groups = [ProductGroup]()
    var cart = ProductGroup(name: NSLocalizedString("Cart", comment: ""), products: []) {
        didSet {
            cartView?.number = cart.products.count
        }
    }

    var cartView: CartView? {
        return navigationItem.rightBarButtonItem?.customView as? CartView
    }

    var filterString = ""
    var selectedGroups: [ProductGroup] = [] {
        didSet {
            selectedTypeView.isHidden = selectedGroups.isEmpty

            DispatchQueue.main.async {
                self.selectionCollectionView.reloadData()
                self.collectionView.reloadData()
            }
        }
    }

    // MARK: - Computed Variables
    var filteredGroups: [ProductGroup] {
        guard !filterString.isEmpty else {
            return self.groups
        }

        var groups = self.groups
        for index in 0..<groups.count {
            let products = groups[index].products
            groups[index].products = products.filter {
                $0.title.contains(filterString)
            }
        }
        return groups
    }

    var favoriteGroup: ProductGroup {
        let products = groups.flatMap { $0.products }.filter { ProductFavoritesManager.favoritesContainsProduct($0) }
        return ProductGroup(name: "Favorites", products: products)
    }

    var displayGroups: [ProductGroup] {
        let groups =  filterString.isEmpty ? ([favoriteGroup] + self.groups) : filteredGroups

        if !selectedGroups.isEmpty {
            return groups.filter { selectedGroups.contains($0) }
        }

        return groups
    }


    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).sectionHeadersPinToVisibleBounds = true
         NotificationCenter.default.addObserver(self, selector: #selector(favoriteChanged), name: .favoriteChanged, object: nil)
        //collectionView.prefetchDataSource = self
        loadAisle()


        let cartView = CartView.initFromXib(with: cart.products.count)
        cartView.delegate = self

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: cartView)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.endEditing(true)
    }

    @objc func favoriteChanged() {
        collectionView.reloadData()
    }

    //MARK - Overriden View Controller methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let typeSelectionVC = segue.destination as? ProductSelectionCollectionViewController {
            typeSelectionVC.productGroups = groups
            typeSelectionVC.selectedGroups = Set(selectedGroups)
            typeSelectionVC.typeSelectionDelegate = self
        }


        else if let cartVC = segue.destination as? ProductCartTableViewController {
            cartVC.cartDelegate = self
            cartVC.cart = cart
        }

        guard let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first, let detailVC = segue.destination as? ProductDetailViewController else {
            return
        }
        collectionView.deselectItem(at: selectedIndexPath, animated: false)
        detailVC.product = productAtIndexPath(selectedIndexPath)
        detailVC.cart = cart
        detailVC.cartDelegate = self
    }

    // MARK: - Loading methods
    private func loadAisle() {
        DispatchQueue.main.async {
            self.aisleLoadingIndicator.startAnimating()
        }

        ProductProvider.getAisle { [weak self] (aisle, error) in
            DispatchQueue.main.async {
                self?.aisleLoadingIndicator.stopAnimating()
                self?.collectionView.isHidden = false
            }

            guard error == nil else {
                self?.showAlertForError(error!)
                return
            }

            guard let aisle = aisle else {
                self?.showAlertForError(ProductProvider.ProductProviderError.noData)
                return
            }

            self?.groups = aisle.groups

            DispatchQueue.main.async {
                self?.title = aisle.title
                self?.wineTypeSelectionButton.isEnabled = true
                self?.collectionView.reloadData()
            }
        }
    }

    // MARK: - Helper Methods
    private func productAtIndexPath(_ indexPath: IndexPath) -> Product? {
        return displayGroups[indexPath.section].products[indexPath.row]
    }
}

// MARK: - SearchBar Delegate
extension ProductAisleViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterString = searchText

        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

}

//MARK: - Collection view DataSource
extension ProductAisleViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if collectionView == selectionCollectionView {
            return
        }

        self.view.endEditing(true)
        performSegue(withIdentifier: "showProductDetail", sender: self)
    }
}

//extension ProductAisleViewController: UICollectionViewDataSourcePrefetching {
//    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
//        ProductProvider.getImagesForAsset(<#T##asset: ProductAsset##ProductAsset#>, completion: <#T##(UIImage?, Error?) -> Void#>)
//    }
//}

extension ProductAisleViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        if collectionView == selectionCollectionView {
            return UICollectionReusableView()
        }

        if displayGroups[indexPath.section].products.isEmpty {
            return UICollectionReusableView()
        }


        let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as! ProductSectionHeaderView

        sectionHeader.leftStarIcon.isHidden = displayGroups[indexPath.section] != favoriteGroup
        sectionHeader.rightStarIcon.isHidden = displayGroups[indexPath.section] != favoriteGroup

        sectionHeader.headerLabel.text = displayGroups[indexPath.section].name

        return sectionHeader
    }


    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == selectionCollectionView {
            return 1
        }
        return displayGroups.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == selectionCollectionView {
            return selectedGroups.count
        }
        return displayGroups[section].products.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if collectionView == selectionCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedGroupsCollectionViewCell.reuseIdentifier, for: indexPath) as! SelectedGroupsCollectionViewCell
            cell.nameLabel.text = selectedGroups[indexPath.item].name
            cell.delegate = self

            cell.layer.cornerRadius = 8.0

            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCollectionViewCell

        guard let product = productAtIndexPath(indexPath), let asset = product.assets.first else {
            return cell
        }
        cell.titleLabel.text = product.title
        cell.titleLabel.boldedSubstring(filterString)


        cell.activityIndicator.startAnimating()
        ProductProvider.getImagesForAsset(asset) { [weak self] (image, error) in

            DispatchQueue.main.async {
                cell.activityIndicator.stopAnimating()
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
                cell.imageView.image = image
            }
        }
        return cell
    }
    
}

extension ProductAisleViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if collectionView == selectionCollectionView {
            return CGSize.zero
        }

        return displayGroups[section].products.isEmpty ? CGSize.zero : CGSize(width: collectionView.frame.width, height: 35)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == selectionCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedGroupsCollectionViewCell.reuseIdentifier, for: indexPath) as! SelectedGroupsCollectionViewCell
            return CGSize(width: cell.widthForName(selectedGroups[indexPath.row].name), height: 25)
        }

        return CGSize(width: 146, height: 164)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == selectionCollectionView {
            return UIEdgeInsets.zero
        }
        if displayGroups[section].products.isEmpty {
            return UIEdgeInsets.zero
        }
        else {
            return UIEdgeInsets(top: 10, left: 35, bottom: 10, right: 35)
        }
    }
}

extension ProductAisleViewController: SelectedGroupCellRemovable {
    func removeSelectedCell(_ cell: SelectedGroupsCollectionViewCell) {
        guard let index = selectionCollectionView.indexPath(for: cell) else {
            return
        }
        selectedGroups.remove(at: index.item)
    }


}

//MARK: - Type selection delegate
extension ProductAisleViewController: ProductTypeSelectionDelegate {
    func didSelectGroups(_ groups: [ProductGroup]) {
        selectedGroups = groups
    }
}

//MARK: - Cart Updatable Delegate
extension ProductAisleViewController: CartUpdatable {
    func updateCart(_ cart: ProductGroup) {
        self.cart = cart
    }
}

//MARK: - Show Cart Delegate
extension ProductAisleViewController: CartSelectable {
    func showCart() {
        performSegue(withIdentifier: "showCart", sender: nil)
    }
}
