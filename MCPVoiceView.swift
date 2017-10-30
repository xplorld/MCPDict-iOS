//
//  MCPVoiceView.swift
//  HanziVoice
//
//  Created by Xplorld on 2017/7/30.
//  Copyright © 2017年 Xplorld. All rights reserved.
//

import UIKit

@IBDesignable class MCPVoiceView: UIView {

    let imageView = UIImageView()
    
    let textLabel = UILabel()
    
    @IBInspectable var image:UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
        }
    }
    
    //just for interface builder
    @IBInspectable var text:String? {
        get {
            return attributedText?.string
        }
        set {
            if let string = newValue {
                attributedText = NSAttributedString(string: string)
            } else {
                attributedText = nil
            }
        }
    }
    
    var attributedText:NSAttributedString? {
        get {
            return textLabel.attributedText
        }
        set {
            textLabel.attributedText = newValue
//            textLabel.sizeToFit()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.initialize()
    }
    
    func initialize() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageView)
        self.addSubview(textLabel)
        
        self.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        self.topAnchor.constraint(equalTo: imageView.topAnchor).isActive = true
        self.bottomAnchor.constraint(greaterThanOrEqualTo: imageView.bottomAnchor).isActive = true
        imageView.contentMode = .scaleAspectFit
        imageView.heightAnchor.constraint(equalToConstant: 20) //magic...
        //cannot be wider than intrinstic
        imageView.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
        
        self.topAnchor.constraint(equalTo: textLabel.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: textLabel.bottomAnchor).isActive = true
        textLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8).isActive = true
        textLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        textLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, for: .horizontal)
        textLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, for: .vertical)
        
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .natural
        textLabel.isUserInteractionEnabled = true
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
