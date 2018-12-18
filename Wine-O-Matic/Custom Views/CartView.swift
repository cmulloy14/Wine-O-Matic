//
//  CartView.swift
//  Wine-O-Matic
//
//  Created by Mulloy, Charles on 12/17/18.
//  Copyright © 2018 Pat Mulloy. All rights reserved.
//

import UIKit

protocol CartSelectable: class {
    func showCart()
}

class CartView: UIView {

    @IBOutlet weak var badge: UILabel!
    weak var delegate: CartSelectable?

    var number: Int {
        get {
            return Int(badge.text ?? "0") ?? 0
        }

        set {
            let initialValue = number
            guard number != newValue  else {
                return
            }

            badge.isHidden = newValue <= 0
            badge.text = String(newValue)

            guard initialValue >= 0 else {
                return
            }

            UIView.animate(withDuration: 1.0, animations: {
                self.badge.transform = self.badge.transform.scaledBy(x: 1.5, y: 1.5)
            }) { (_) in
                UIView.animate(withDuration: 1.0, animations: {
                    self.badge.transform = self.badge.transform.scaledBy(x: 0.666667, y: 0.666667)
                })
            }
        }
    }

    @IBAction func showCart(_ sender: Any) {
        
        delegate?.showCart()
    }

    static func initFromXib(with number: Int) -> CartView {
        let xib = UINib.init(nibName: "CartView", bundle: nil)
        let view = xib.instantiate(withOwner: nil, options: nil).first as! CartView

        view.badge.layer.cornerRadius = 8.0
        view.badge.layer.backgroundColor = UIColor.red.cgColor

        view.number = number
        return view
    }


}
