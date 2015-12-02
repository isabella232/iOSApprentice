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
    
    var searchResults = [SearchResult]()
    
    var hasSearched = false
    
    
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
        
        searchBar.resignFirstResponder()
        
        hasSearched = true
        
        searchResults = [SearchResult]()

        if searchBar.text! != "justin bieber"{
            
            for i in 0...2 {
                
                let searchResult = SearchResult()
                
                searchResult.name = String(format: "Fake Result %d for ",i)
                
                searchResult.artistName = searchBar.text!
                
                searchResults.append(searchResult)
                
            }
        }
        
        tableView.reloadData()
    }

}

extension SearchViewController:UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if !hasSearched {
        
            return 0
        
        } else if searchResults.count == 0 {
            
            return 1
        
        } else {
        
           return searchResults.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifer = "SearchResultCell"
        
        var cell:UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellIdentifer)
        
        if cell == nil {
        
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellIdentifer)
        
        }
        
        if searchResults.count == 0 {
            
            cell.textLabel!.text = "(Nothing to found)"
            
            cell.detailTextLabel!.text = ""
        
        } else {
        
            let searchResult = searchResults[indexPath.row]
            
            cell.textLabel!.text = searchResult.name
            
            cell.detailTextLabel!.text = searchResult.artistName
        
        }
        
        return cell
    }

}

extension SearchViewController:UITableViewDelegate {

    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        
        return .TopAttached
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        
        if searchResults.count == 0 {
        
            return nil
            
        } else {
        
            return indexPath
        }
    }
    

}

