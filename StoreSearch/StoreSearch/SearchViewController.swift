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
    
    
    struct TableViewCellIdentifiers {
        
        static let searchResultCell = "SearchResultCell"
        
        static let nothingFoundCell = "NothingFoundCell"
    }
    
    override func viewDidLoad() {
        
        searchBar.becomeFirstResponder()
        
        tableView.rowHeight = 80
        
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
    }

    
    /**
     内存提醒
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func urlWithSearchText(searchText:String)->NSURL {
    
        let escapedSearchText = searchText.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        
        let urlString = String(format: "https://itunes.apple.com/search?term=%@", escapedSearchText!)
        
        let url = NSURL(string: urlString)
        
        return url!
        
    }
    
    func performStoreRequestWithURL(url:NSURL) -> String?{
    
        do {
            
            return try String(contentsOfURL: url, encoding: NSUTF8StringEncoding)
        } catch {
        
            print("Download Error:\(error)")
            
            return nil
        
        
        }
    
    }
    
    func parseJson(jsonString: String) -> [String:AnyObject]? {
    
        
        guard let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
        
            else {return nil}
        
        do {
        
            return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject]
        
        } catch{
        
            print("Json Error:\(error)")
            
            return nil
        }
    
    }
    
    func showNetworkError(){
    
        let alert = UIAlertController(
            title: "Whoops...", message: "There was an error reading from the iTunes Store.please try again .", preferredStyle: .Alert)
        
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        
        presentViewController(alert, animated: true, completion: nil)
    
    }
    
    
    func parseDictionary(dictionary:[String:AnyObject]) -> [SearchResult]{
    
        guard let array = dictionary["results"] as? [AnyObject] else {
        
            print("Excepted 'results' array")
            
            return []
        }
        
        var searchResults = [SearchResult]()
        
        for resultDict in array {
            
            if let resultDict = resultDict as? [String:AnyObject]{
            
                var searchResult: SearchResult?
                
                if let wrapperType = resultDict["wrapperType"] as? String {
                    
                    
                    switch wrapperType {
                    
                    case "track":
                        searchResult = parseTrack(resultDict)
                    default:
                        break;
                    }
                }
                
                if let result = searchResult {
                    searchResults.append(result)
                }
            }
        }
        
        return searchResults
        
    }
    
    func parseTrack(dictionary:[String:AnyObject]) -> SearchResult {
        
        let searchResult = SearchResult()
        
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        
        if let price = dictionary["trackPrice"] as? Double {
        
            searchResult.price = price
        
        }
        
        if let genre = dictionary["primaryGenreName"] as? String {
        
            searchResult.genre = genre
        
        }
        
        return searchResult
    
    }
}


extension SearchViewController:UISearchBarDelegate {

    /**
     查询栏输入事件
     
     - parameter searchBar: 查询栏
     */
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        if !searchBar.text!.isEmpty {
            
            searchBar.resignFirstResponder()
            
            hasSearched = true
            
            searchResults = [SearchResult]()
            
            let url = urlWithSearchText(searchBar.text!)
            
            print("URL:\(url)")
            
            if let jsonString = performStoreRequestWithURL(url){
            
                if let dictionary = parseJson(jsonString) {
                    
                    print("Dictionary \(dictionary)")
                    
                    searchResults = parseDictionary(dictionary)
                    
                    tableView.reloadData()
                    return
                }
            
            }
            showNetworkError()
            
        }
        
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
        
        
        if searchResults.count == 0 {
            
            return tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath)
        
        } else {
        
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as! SearchResultCell
            
            let searchResult = searchResults[indexPath.row]
            
            cell.nameLabel.text = searchResult.name
            
            
            if searchResult.artistName.isEmpty {
            
                cell.artistNameLabel.text = "unknown"
            } else {
            
                cell.artistNameLabel.text = String(format: "%@ (%@)", searchResult.artistName, searchResult.kind)
            }
             return cell
        
        }
       
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

