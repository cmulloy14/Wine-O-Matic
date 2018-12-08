//
//  ProductAisleViewController.swift
//  Wine-O-Matic
//
//  Created by Mulloy, Charles on 12/5/18.
//  Copyright © 2018 Pat Mulloy. All rights reserved.
//

import UIKit

class ProductAisleViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    var groups = [ProductGroup]()

    var filterString = ""
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
        return filterString.isEmpty ? ([favoriteGroup] + groups) : filteredGroups
    }


    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        ProductProvider.getAisle { (aisle, error) in
            if let error = error {
                self.showAlertForError(error)
                return
            }

            guard let aisle = aisle else {
                self.showAlertForError(ProductProvider.ProductProviderError.noData)
                return
            }

            self.groups = aisle.groups
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let selectedIndexPath = tableView.indexPathForSelectedRow, let detailVC = segue.destination as? ProductDetailViewController else {
            return
        }
        tableView.deselectRow(at: selectedIndexPath, animated: true)
        detailVC.product = productAtIndexPath(selectedIndexPath)
    }

    private func productAtIndexPath(_ indexPath: IndexPath) -> Product? {
        return displayGroups[indexPath.section].products[indexPath.row]
    }
}

// MARK: - SearchBar Delegate
extension ProductAisleViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterString = searchText

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

}

// MARK: - TableView Datasource
extension ProductAisleViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return displayGroups[section].products.isEmpty ? nil : displayGroups[section].name
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return displayGroups.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayGroups[section].products.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
        cell.textLabel?.text = productAtIndexPath(indexPath)?.title ?? ""
        cell.textLabel?.boldedSubstring(filterString)

        return cell
    }
}

// MARK: - TableView Delegate
extension ProductAisleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showProductDetail", sender: self)
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard let product = self.productAtIndexPath(indexPath) else {
            return nil
        }
        let isFavorite = ProductFavoritesManager.favoritesContainsProduct(product)

        let style: UITableViewRowAction.Style = isFavorite ? .destructive : .default
        let title = isFavorite ? NSLocalizedString("Remove from Favorites", comment: "") : NSLocalizedString("Add to Favorites", comment: "")
        let action = UITableViewRowAction(style: style, title: title) { (action, indexPath) in
            do {
                try ProductFavoritesManager.toggleFavorite(product: product)
            }
            catch {
                self.showAlertForError(error)
            }

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }

        return [action]
    }
}
