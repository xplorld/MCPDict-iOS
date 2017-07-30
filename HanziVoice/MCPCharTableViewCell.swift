//
//  MCPCharTableViewCell.swift
//  HanziVoice
//
//  Created by Xplorld on 2017/7/30.
//  Copyright © 2017年 Xplorld. All rights reserved.
//

import UIKit

class MCPCharTableViewCell: UITableViewCell {
    static let identifier = "MCPCharTableViewCell"
    
    @IBOutlet weak var valueLabel: UILabel!
    
    @IBOutlet weak var unicodeLabel: UILabel!
    
    
    @IBOutlet weak var middleChineseView: MCPVoiceView!
    
    @IBOutlet weak var mandrinView: MCPVoiceView!
    
    @IBOutlet weak var cantoneseView: MCPVoiceView!
    
    @IBOutlet weak var shanghaieseView: MCPVoiceView!
    
    @IBOutlet weak var minnaneseView: MCPVoiceView!
    
    @IBOutlet weak var koreanView: MCPVoiceView!
    
    @IBOutlet weak var vietnameseView: MCPVoiceView!
    
    @IBOutlet weak var japaneseGoView: MCPVoiceView!
    
    @IBOutlet weak var japaneseKanView: MCPVoiceView!
    
    weak var model:MCPChar? {
        didSet {
            bindTo(model:model)
        }
    }
    func bindTo(model: MCPChar?) {
        let viewMap:[MCPDictItemColumn:MCPVoiceView] = [
            .middleChinese: self.middleChineseView,
            .mandrin: self.mandrinView,
            .cantonese: self.cantoneseView,
            .wu: self.shanghaieseView,
            .min: self.minnaneseView,
            .korean: self.koreanView,
            .vietnamese: self.vietnameseView,
            .jp_go: self.japaneseGoView,
            .jp_kan: self.japaneseKanView
        ]
        for view in viewMap.values {
            view.attributedText = NSAttributedString(string: "-")
        }
        //if model == nil, do nothing
        if let model = model {
            valueLabel.text = model.value
            unicodeLabel.text = "U+" + model.unicode
            for voice in model.voices {
                if viewMap.keys.contains(voice.type) {
                    viewMap[voice.type]?.attributedText = voice.formatted()
                }
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
