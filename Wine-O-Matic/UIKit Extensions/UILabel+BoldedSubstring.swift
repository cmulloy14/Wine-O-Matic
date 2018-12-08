//
//  UILabel+BoldedSubstring.swift
//  Wine-O-Matic
//
//  Created by Mulloy, Charles on 12/7/18.
//  Copyright © 2018 Pat Mulloy. All rights reserved.
//

import UIKit

extension UILabel {

    // Bold the given substring within the label's text. No bolding with an empty substring 
    func boldedSubstring(_ string: String) {
        guard
            let text = text,
            let regex = try? NSRegularExpression.init(pattern: string, options: NSRegularExpression.Options.caseInsensitive),
            !string.isEmpty
            else {
                attributedText = NSAttributedString(string: self.text ?? "")
                return
        }

        let range = NSRange(location: 0, length: text.count)
        let attributedString = NSMutableAttributedString(string: text)
        let matches = regex.matches(in: text, options: [], range: range)

        matches.forEach {
            attributedString.addAttributes([.font : UIFont.boldSystemFont(ofSize: font.pointSize)], range: $0.range)
        }

        attributedText = attributedString
    }

}
