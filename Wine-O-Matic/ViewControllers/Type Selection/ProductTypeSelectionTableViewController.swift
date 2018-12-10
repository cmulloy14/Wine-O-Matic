//
//  ProductTypeSelectionTableViewController.swift
//  Wine-O-Matic
//
//  Created by Mulloy, Charles on 12/10/18.
//  Copyright © 2018 Pat Mulloy. All rights reserved.
//

import UIKit

protocol ProductTypeSelectionDelegate {
    func didSelectType(_ type: String)
}

class ProductTypeSelectionTableViewController: UITableViewController {

    var types: [String]!
    var typeSelectionDelegate: ProductTypeSelectionDelegate?

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return types.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TypeCell", for: indexPath)
        cell.textLabel?.text = types[indexPath.row]
        return cell
    }

    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        typeSelectionDelegate?.didSelectType(types[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: false)
        navigationController?.popViewController(animated: true)
    }


}
