//
//  MCPSearchOptionsTableViewController.swift
//  HanziVoice
//
//  Created by Xplorld on 2017/10/21.
//  Copyright © 2017年 Xplorld. All rights reserved.
//

import UIKit

protocol MCPSearchOptionsTableViewControllerDelegate : class {
    func beginSearch(text: String, options: MCPSearchOptions)
}

class MCPSearchOptionsTableViewController: UITableViewController {

    // MARK: - Table view data source

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var queryModeButton: UIButton!
    
    @IBOutlet weak var searchInKuangxYonhOnly: UISwitch!
    
    @IBOutlet weak var allowVariants: UISwitch!
    
    @IBOutlet weak var toneInsensitive: UISwitch!
    
    weak var delegate: MCPSearchOptionsTableViewControllerDelegate?
    
    var data = MCPSearchOptions()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        syncDataToView()
        
        searchInKuangxYonhOnly.addTarget(self, action: #selector(SetSwitchValue), for: .valueChanged)
        allowVariants.addTarget(self, action: #selector(SetSwitchValue), for: .valueChanged)
        toneInsensitive.addTarget(self, action: #selector(SetSwitchValue), for: .valueChanged)
    }
    
    
    @IBAction func SetSwitchValue(_ sender: UISwitch) {
//        switch sender {
//        case searchInKuangxYonhOnly:
            data.searchInKuangxYonhOnly = sender.isOn
//        case allowVariants:
            data.allowVariants = sender.isOn
//        case toneInsensitive:
            data.toneInsensitive = sender.isOn
//        default:
//            break
//        }
    }
    
    func syncDataToView() {
        searchInKuangxYonhOnly.isOn = data.searchInKuangxYonhOnly
        allowVariants.isOn = data.allowVariants
        toneInsensitive.isOn = data.toneInsensitive
    }
    
    override func becomeFirstResponder() -> Bool {
        return searchBar.becomeFirstResponder()
    }
    override func resignFirstResponder() -> Bool {
        return searchBar.resignFirstResponder()
    }
}

extension MCPSearchOptionsTableViewController : UISearchBarDelegate
{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let text = searchBar.text ?? ""
        delegate?.beginSearch(text: text, options: data)
    }
}
