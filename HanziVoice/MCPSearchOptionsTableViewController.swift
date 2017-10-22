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
    func setSearchDetailView(active:Bool)
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
        tableView.allowsSelection = false
        
        searchBar.delegate = self
        syncDataToView()
        
        queryModeButton.addTarget(self, action: #selector(selectQueryMode), for: .touchUpInside)
        searchInKuangxYonhOnly.addTarget(self, action: #selector(syncSwitchDataToView), for: .valueChanged)
        allowVariants.addTarget(self, action: #selector(syncSwitchDataToView), for: .valueChanged)
        toneInsensitive.addTarget(self, action: #selector(syncSwitchDataToView), for: .valueChanged)
    }
    
    
    func syncSwitchDataToView(_ sender: UISwitch) {
        switch sender {
        case searchInKuangxYonhOnly:
            data.searchInKuangxYonhOnly = searchInKuangxYonhOnly.isOn
        case allowVariants:
            data.allowVariants = allowVariants.isOn
        case toneInsensitive:
            data.toneInsensitive = toneInsensitive.isOn
        default:
            break
        }
    }
    
    func syncDataToView() {
        queryModeButton.setTitle(data.queryMode.displayName, for: .normal)
        searchInKuangxYonhOnly.isOn = data.searchInKuangxYonhOnly
        allowVariants.isOn = data.allowVariants
        toneInsensitive.isOn = data.toneInsensitive
    }
    
    func selectQueryMode() {
        let alert = UIAlertController(title: "查询模式", message: "请选择查询模式。", preferredStyle: .actionSheet)
        for type in MCPDictItemColumn.queryTypes() {
            alert.addAction(
                UIAlertAction(title: type.displayName,
                              style: .default) {
                                [weak self] _ in
                                self?.data.queryMode = type
                                self?.syncDataToView()
            })
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        delegate?.setSearchDetailView(active: false)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let text = searchBar.text ?? ""
        delegate?.beginSearch(text: text, options: data)
    }
}
