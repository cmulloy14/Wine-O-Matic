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

    var aisle: ProductAisle?

    override func viewDidLoad() {
        super.viewDidLoad()

        ProductProvider.getAisle { (aisle, error) in
            if let error = error {
                print(error)
                return
            }
            self.aisle = aisle

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
        return aisle?.groups[indexPath.section].products[indexPath.row]
    }
}

// MARK: - Table View Datasource
extension ProductAisleViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return aisle?.groups[section].name ?? ""
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return aisle?.groups.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aisle?.groups[section].products.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)

        cell.textLabel?.text = productAtIndexPath(indexPath)?.title ?? ""

        return cell
    }
}

// MARK: - Table View Delegate
extension ProductAisleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showProductDetail", sender: self)
    }
}
