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
    @IBOutlet weak var selectedTypeLabel: UILabel!


    //MARK: - Instance Variables
    var groups = [ProductGroup]()
    var filterString = ""
    var selectedType: String? {
        didSet {
            selectedTypeView.isHidden = selectedType == nil
            selectedTypeLabel.text = selectedType
            DispatchQueue.main.async {
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

        if let selectedType = selectedType {
            return groups.filter { $0.name == selectedType }
        }

        return groups
    }


    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).sectionHeadersPinToVisibleBounds = true
         NotificationCenter.default.addObserver(self, selector: #selector(favoriteChanged), name: .favoriteChanged, object: nil)

        loadAisle()
    }

    @IBAction func removeSelectedType(_ sender: Any) {
        selectedType = nil
    }

    @objc func favoriteChanged() {
        collectionView.reloadData()
    }


    //MARK - Overriden View Controller methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let typeSelectionVC = segue.destination as? ProductTypeSelectionTableViewController {
            typeSelectionVC.types = groups.map { $0.name }
            typeSelectionVC.typeSelectionDelegate = self
        }

        guard let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first, let detailVC = segue.destination as? ProductDetailViewController else {
            return
        }
        collectionView.deselectItem(at: selectedIndexPath, animated: false)
        detailVC.product = productAtIndexPath(selectedIndexPath)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    // MARK: - Loading methods
    private func loadAisle() {
        DispatchQueue.main.async {
            self.aisleLoadingIndicator.startAnimating()
        }

        ProductProvider.getAisle(fromLocal: true) { [weak self] (aisle, error) in
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
        self.view.endEditing(true)
        performSegue(withIdentifier: "showProductDetail", sender: self)
    }
}

extension ProductAisleViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        if displayGroups[indexPath.section].products.isEmpty {
            return UICollectionReusableView.init()
        }

        let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as! ProductSectionHeaderView

        sectionHeader.headerLabel.text = displayGroups[indexPath.section].name

        return sectionHeader
    }


    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return displayGroups.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayGroups[section].products.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCollectionViewCell

        guard let product = productAtIndexPath(indexPath), let asset = product.assets.first else {
            return cell
        }
        cell.titleLabel.text = product.title

        ProductProvider.getImagesForAsset(asset) { [weak self] (image, error) in

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
        return displayGroups[section].products.isEmpty ? CGSize.zero : CGSize(width: collectionView.frame.width, height: 35)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if displayGroups[section].products.isEmpty {
            return UIEdgeInsets(top: CGFloat.leastNonzeroMagnitude, left: CGFloat.leastNonzeroMagnitude, bottom: CGFloat.leastNonzeroMagnitude, right: CGFloat.leastNonzeroMagnitude)
        }
        else {
            return UIEdgeInsets(top: 10, left: 35, bottom: 10, right: 35)
        }
    }
}


//MARK: - Type selection delegate
extension ProductAisleViewController: ProductTypeSelectionDelegate {
    func didSelectType(_ type: String) {
        guard selectedType != type else {
            return
        }

        selectedType = type
    }
}
