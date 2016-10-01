//
//  TextHero.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 6/1/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class TextHero: UIView, IAmCardContents {
    
    @IBOutlet weak var textHero: UILabel!
    
    func bindCard(card: Card) {
        textHero.text = card.text
    }
    
    func addFrame() {
        let offset = frame.width / 10
        let size = CGSize(width: frame.width - offset * 2, height: frame.height - offset * 2)
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: offset, y: offset), size: size))
        addSubview(imageView)
        imageView.image = UIImage.frame(size, color: UIColor.blackColor().CGColor)
    }

}
