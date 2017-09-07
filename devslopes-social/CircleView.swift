//
//  CircleView.swift
//  devslopes-social
//
//  Created by James McLean on 06/09/2017.
//  Copyright © 2017 James McLean. All rights reserved.
//

import UIKit

class CircleView: UIImageView {
    
    override func layoutSubviews() {
        layer.cornerRadius = self.frame.width / 2
        clipsToBounds = true
    }

}
