//
//  ViewController+ErrorHandling.swift
//  Wine-O-Matic
//
//  Created by Mulloy, Charles on 12/5/18.
//  Copyright © 2018 Pat Mulloy. All rights reserved.
//

import UIKit

extension UIViewController {

    // Display an alert with the errors description and an "Ok" button to dismiss 
    func showAlertForError(_ error: Error) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: error.localizedDescription, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
