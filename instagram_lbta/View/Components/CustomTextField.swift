//
//  CustomTextField.swift
//  instagram_lbta
//
//  Created by Gokhan Demirer on 10.05.2018.
//  Copyright © 2018 Gokhan Demirer. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.clearButtonMode = .whileEditing
        self.backgroundColor = UIColor(r: 250, g: 250, b: 250)
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(r: 227, g: 227, b: 227).cgColor
        self.layer.cornerRadius = 6
        self.font = UIFont.systemFont(ofSize: 14)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 16, y: bounds.origin.y, width: bounds.width - 16, height: bounds.height)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 16, y: bounds.origin.y, width: bounds.width - 16, height: bounds.height)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 16, y: bounds.origin.y, width: bounds.width - 16, height: bounds.height)
    }
}
