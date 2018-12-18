//
//  SelectedGroupsCollectionViewCell.swift
//  Wine-O-Matic
//
//  Created by Mulloy, Charles on 12/15/18.
//  Copyright © 2018 Pat Mulloy. All rights reserved.
//

import UIKit

protocol SelectedGroupCellRemovable: class  {
    func removeSelectedCell(_ cell: SelectedGroupsCollectionViewCell)
}

class SelectedGroupsCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = "SelectionCell"
    weak var delegate: SelectedGroupCellRemovable?

    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var labelNameSpacingConstraint: NSLayoutConstraint!


    @IBAction func removeSelectedGroup(_ sender: Any) {
        delegate?.removeSelectedCell(self)
    }

    func widthForName(_ name: String) -> CGFloat {
        let labelWidth = (name as NSString).size(withAttributes: [.font: nameLabel.font]).width
        return labelWidth + labelNameSpacingConstraint.constant + removeButton.frame.size.width
    }

}
