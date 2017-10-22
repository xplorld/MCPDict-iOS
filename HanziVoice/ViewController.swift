//
//  ViewController.swift
//  HanziVoice
//
//  Created by Xplorld on 2017/7/26.
//  Copyright © 2017年 Xplorld. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let SEARCH_DETAIL_VIEW_ANIMATION_DURATION:TimeInterval = 0.5
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        setSearchDetailView(active: true)
    }
    @IBOutlet weak var searchDetailView: UIView!
    weak var searchOptionsViewController : MCPSearchOptionsTableViewController! {
        didSet {
            searchOptionsViewController?.delegate = self
        }
    }
    
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
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 135
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if chars.isEmpty {
            setSearchDetailView(active: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "MainToSearchOptionsSegue") {
            searchOptionsViewController = segue.destination as! MCPSearchOptionsTableViewController
        }
    }

}


extension ViewController : MCPSearchOptionsTableViewControllerDelegate {
    
    func setSearchDetailView(active:Bool)
    {
        if (active == !searchDetailView.isHidden) {
            return
        }
        //if `active` mismatches hidden status,
        //perform action and set first responder to search view
        //(who sets first responder to search bar)
        if active == false {
            
            UIView.transition(with: searchDetailView,
                              duration: SEARCH_DETAIL_VIEW_ANIMATION_DURATION,
                              options: .transitionCrossDissolve ,
                              animations: {
                                [weak self] in
                                let _ = self?.searchOptionsViewController.resignFirstResponder()
                                self?.searchDetailView.isHidden = true
                },
                              completion: nil)
        } else {
            UIView.transition(with: searchDetailView,
                              duration: SEARCH_DETAIL_VIEW_ANIMATION_DURATION,
                              options: .transitionCrossDissolve,
                              animations: {
                                [weak self] in
                                self?.searchDetailView.isHidden = false
                                let _ = self?.searchOptionsViewController.becomeFirstResponder()
                },
                              completion: nil)
            
        }
        
    }

    func beginSearch(text: String, options: MCPSearchOptions) {
        self.chars = db.search(keyword: text, options: options)
        setSearchDetailView(active: false)
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setSearchDetailView(active: false)
    }
}
