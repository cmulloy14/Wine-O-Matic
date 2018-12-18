//
//  ProductSelectionCollectionViewController.swift
//  Wine-O-Matic
//
//  Created by Mulloy, Charles on 12/15/18.
//  Copyright © 2018 Pat Mulloy. All rights reserved.
//

import UIKit

private let reuseIdentifier = "ProductCell"

protocol ProductTypeSelectionDelegate {
    func didSelectGroups(_ groups: [ProductGroup])
}

class ProductSelectionCollectionViewController: UICollectionViewController {

    var productGroups: [ProductGroup]!
    var selectedGroups: Set<ProductGroup>!

    var typeSelectionDelegate: ProductTypeSelectionDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.allowsMultipleSelection = true
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        typeSelectionDelegate?.didSelectGroups(Array(selectedGroups).sorted(by: { (group1, group2) -> Bool in
            return productGroups.firstIndex(of: group1) ?? 0 < productGroups.firstIndex(of: group2) ?? 0 
        }))
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return productGroups.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ProductCollectionViewCell

        let productGroup = productGroups[indexPath.item]
        cell.titleLabel.text = productGroup.name


        guard let asset = productGroup.products.first?.assets.first else {
            return cell
        }

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

        if selectedGroups.contains(productGroups[indexPath.item]) {
            cell.layer.borderWidth = 2.0
            cell.layer.borderColor = UIColor.purple.cgColor
        }

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedGroups.insert(productGroups[indexPath.item])
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderWidth = 2.0
        cell?.layer.borderColor = UIColor.purple.cgColor
    }

    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        selectedGroups.remove(productGroups[indexPath.item])
        collectionView.cellForItem(at: indexPath)?.layer.borderWidth = 0
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
