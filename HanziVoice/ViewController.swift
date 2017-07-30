//
//  ViewController.swift
//  HanziVoice
//
//  Created by Xplorld on 2017/7/26.
//  Copyright © 2017年 Xplorld. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var queryMode: UIButton!
    
    @IBOutlet weak var searchInKuangxYonhOnly: UISwitch!
    @IBOutlet weak var allowVariants: UISwitch!
    @IBOutlet weak var toneInsensitive: UISwitch!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    let db = MCPDictDB()
    var chars:[MCPChar] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 135
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


extension ViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let text = searchBar.text ?? ""
        self.chars = db.search(text)
        
    }
}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chars.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: MCPCharTableViewCell.identifier) as! MCPCharTableViewCell
        let char = self.chars[indexPath.row]
        cell.model = char
        return cell
    }
}
