//
//  ViewController.swift
//  StoreSearch
//
//  Created by Jay on 15/11/30.
//  Copyright © 2015年 look4us. All rights reserved.
//

import UIKit


class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar:UISearchBar!
    
    @IBOutlet weak var tableView:UITableView!
    
    var searchResults = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
    }

    /**
     内存提醒
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


extension SearchViewController:UISearchBarDelegate {

    /**
     查询栏输入事件
     
     - parameter searchBar: 查询栏
     */
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        searchResults = [String]()
        
        for i in 0...2 {
        
            searchResults.append(String(format: "Fake Result %d for '%@'",i,searchBar.text!))
            
        }
        
        tableView.reloadData()
    }

}

extension SearchViewController:UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return searchResults.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifer = "SearchResultCell"
        
        var cell:UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellIdentifer)
        
        if cell == nil {
        
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellIdentifer)
        
        }
        
        cell.textLabel!.text = searchResults[indexPath.row]
        
        return cell
    }

}

extension SearchViewController:UITableViewDelegate {

    

}

