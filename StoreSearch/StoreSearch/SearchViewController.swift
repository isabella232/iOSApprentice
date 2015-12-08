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
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var searchResults = [SearchResult]()
    
    var hasSearched = false
    
    var isLoading  = false
    
    var dataTask: NSURLSessionDataTask?
    
    struct TableViewCellIdentifiers {
        
        static let searchResultCell = "SearchResultCell"
        
        static let nothingFoundCell = "NothingFoundCell"
        
        
        static let loadingCell = "LoadingCell"
    }
    
    override func viewDidLoad() {
        
        searchBar.becomeFirstResponder()
        
        tableView.rowHeight = 80
        
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 108, left: 0, bottom: 0, right: 0)
        
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
    }

    
    /**
     内存提醒
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        
        performSearch()
    }
    

    func urlWithSearchText(searchText:String,category:Int)->NSURL {
    
        let entityName :String
        
        switch category {
        
        case 1:entityName = "musicTrack"
        case 2:entityName = "software"
        case 3:entityName = "ebook"
        default:entityName = ""
            
        }
        
        let escapedSearchText = searchText.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        
        let urlString = String(format: "https://itunes.apple.com/search?term=%@&limit=200&entity=%@",escapedSearchText!,entityName)
        
        let url = NSURL(string: urlString)
        
        return url!
        
    }
    

    
    func parseJson(data: NSData) -> [String:AnyObject]? {
    
       
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
                    case "audiobook":
                        searchResult = parseAudio(resultDict)
                    case "software":
                        searchResult = parseSoftware(resultDict)
                    default:
                        break;
                    }
                } else if let kind = resultDict["kind"] as? String
                
                    where kind == "ebook" {
                
                        searchResult = parseEBook(resultDict)
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
    
    func parseAudio(dictionary:[String:AnyObject]) -> SearchResult {
        
        let searchResult = SearchResult()
        
        searchResult.name = dictionary["collectionName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["collectionViewUrl"] as! String
        searchResult.kind = "audiobook"
        searchResult.currency = dictionary["currency"] as! String
        
        if let price = dictionary["collectionPrice"] as? Double {
            
            searchResult.price = price
            
        }
        
        if let genre = dictionary["primaryGenreName"] as? String {
            
            searchResult.genre = genre
            
        }
        
        return searchResult
        
    }

    func parseSoftware(dictionary:[String:AnyObject]) -> SearchResult {
        
        let searchResult = SearchResult()
        
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        
        if let price = dictionary["price"] as? Double {
            
            searchResult.price = price
            
        }
        
        if let genre = dictionary["primaryGenreName"] as? String {
            
            searchResult.genre = genre
            
        }
        
        return searchResult
        
    }

    func parseEBook(dictionary:[String:AnyObject]) -> SearchResult {
        
        let searchResult = SearchResult()
        
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        
        if let price = dictionary["price"] as? Double {
            
            searchResult.price = price
            
        }
        
        if let genre = dictionary["genres"] as? String {
            
            searchResult.genre = genre
            
        }
        
        return searchResult
        
    }

    
    
    func kindForDisplay(kind:String)->String {
    
        switch kind {
        
            case "album":return "Albun"
            case "audiobook": return "Audio Book"
            case "book": return "Book"
            case "ebook":return "E-Book"
            case "feature-movie": return "Movie"
            case "music-video": return "Music Video"
            case "podcast": return "Podcast"
            case "software": return "App"
            case "song": return "Song"
            case "tv-episode": return "TV Episode"
        default: return kind
        
        }
    }
    
    
}


extension SearchViewController:UISearchBarDelegate {

    /**
     查询栏输入事件
     
     - parameter searchBar: 查询栏
     */
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        performSearch()
    }
    
    
    
     func performSearch (){
        
        if !searchBar.text!.isEmpty {
            
            searchBar.resignFirstResponder()
            
            dataTask?.cancel()
            
            isLoading = true
            
            tableView.reloadData()
            
            
            hasSearched = true
            
            searchResults = [SearchResult]()
            
 
            
            let url = self.urlWithSearchText(searchBar.text!,category: segmentedControl.selectedSegmentIndex)
            
            let session = NSURLSession.sharedSession()
            
            dataTask = session.dataTaskWithURL(url, completionHandler: {
            
                data,response,error in
                
                if let error = error where error.code == -999 {
                
                     return //print("Failure!\(error)")
                
                } else if let httpResponse = response as? NSHTTPURLResponse
                    
                    where httpResponse.statusCode == 200 {
                
                        if let data = data, dictionary = self.parseJson(data) {
                        
                            self.searchResults = self.parseDictionary(dictionary)
                            
                            self.searchResults.sortInPlace(<)
                            
                            dispatch_async(dispatch_get_main_queue()){
                            
                                self.isLoading = false
                                
                                self.tableView.reloadData()
                            
                            }
                        
                        return
                            
                        }
                
                }
                
                dispatch_async(dispatch_get_main_queue()){
                
                    self.hasSearched = false
                    
                    self.isLoading = false
                    
                    self.tableView.reloadData()
                    
                    self.showNetworkError()
                
                }
            })
            
            dataTask?.resume()
        }
        
    }

}

extension SearchViewController:UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isLoading {
            
            return 1
        
        } else if !hasSearched {
        
            return 0
        
        } else if searchResults.count == 0 {
            
            return 1
        
        } else {
        
           return searchResults.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if isLoading {
        
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath: indexPath)
            
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            
            return cell
        
        } else if searchResults.count == 0 {
            
            return tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath)
        
        } else {
        
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as! SearchResultCell
            
            let searchResult = searchResults[indexPath.row]
            
            cell.configureForSearchResult(searchResult)
            
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
        
        if searchResults.count == 0 || isLoading {
        
            return nil
            
        } else {
        
            return indexPath
        }
    }
    

}

