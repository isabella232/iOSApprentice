//
//  LandscapeViewController.swift
//  StoreSearch
//
//  Created by Jay on 15/12/24.
//  Copyright © 2015年 look4us. All rights reserved.
//

import UIKit

class LandscapeViewController: UIViewController {

    @IBOutlet weak var scrollView:UIScrollView!
    
    @IBOutlet weak var pageControll:UIPageControl!
    
    
    var search:Search!
    
    private var firstTime = true
    
    private var downloadTasks = [NSURLSessionDownloadTask]()
    
    deinit {
    
        print("deinti \(self)")
        
        for task in downloadTasks {
            
            task.cancel()
        
        }
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.removeConstraints(view.constraints)
        view.translatesAutoresizingMaskIntoConstraints = true
        
        pageControll.removeConstraints(pageControll.constraints)
        pageControll.translatesAutoresizingMaskIntoConstraints = true
        
        scrollView.removeConstraints(scrollView.constraints)
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        
        scrollView.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
    
        pageControll.numberOfPages = 0

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
     
        super.viewWillLayoutSubviews()
        
        scrollView.frame = view.bounds
        
        pageControll.frame = CGRect(
            
            x: 0, y: view.frame.size.height - pageControll.frame.size.height, width: view.frame.size.width, height: pageControll.frame.size.height)
        
        if firstTime {
        
            firstTime = false
            
            switch search.state {
            case .NotSearchedYet:
                break
            case .Loading:
                break
            case .NoResults:
                break
            case .Results(let list):
                tileButtons(list)
            }
        }
    }
    
    private func tileButtons(searchResults:[SearchResult]){
    
        var columnsPerPage = 5
        
        var rowsPerPage = 3
        
        var itemWidth: CGFloat = 96
        
        var itemHeight: CGFloat = 88
        
        var marginX: CGFloat = 0
        
        var marginY:CGFloat = 20
        
        let scrollViewWidth = scrollView.bounds.size.width
        
        switch scrollViewWidth {
        
        case 568:
            
            columnsPerPage = 6
            
            itemWidth = 94
            
            marginX = 2
            
        case 667:
            columnsPerPage = 7
            itemWidth = 95
            itemHeight = 98
            marginX = 1
            marginY = 29
            
        case 736:
            columnsPerPage = 8
            rowsPerPage = 4
            itemWidth = 92
        default:
            break
        
        }
    
        
        let buttonWidht:CGFloat = 82
        let buttonHeight:CGFloat = 82
        
        let paddingHorz = (itemWidth - buttonWidht)/2
        let paddingVert = (itemHeight - buttonHeight)/2
        
        var row = 0
        var column = 0
        
        var x = marginX
        
        for searchResult in searchResults {
        
            let button =  UIButton(type: .Custom)
            button.setBackgroundImage(UIImage(named: "LandscapeButton"), forState: .Normal)
            
            //button.setTitle("\(index)", forState: .Normal)
            
            button.frame = CGRect(x: x+paddingHorz, y: marginY+CGFloat(row)*itemHeight+paddingVert, width: buttonWidht, height: buttonHeight)
            
            
            scrollView.addSubview(button)
            
            downloadImageForSearchResult(searchResult, andPlaceOnButton: button)
            
            row += 1
            
            if row == rowsPerPage{
            
                row = 0; x += itemWidth; column += 1
                
                if column == columnsPerPage {
                
                    column = 0; x += marginX*2
                    
                }
            }
            
            
        }
        
        let buttonsPerPage = columnsPerPage * rowsPerPage
        
        let numPages = 1 + (searchResults.count - 1) / buttonsPerPage
        
        scrollView.contentSize = CGSize(width: CGFloat(numPages)*scrollViewWidth, height: scrollView.bounds.size.height)
        
        print("Number of Pages:\(numPages)")
        
        pageControll.numberOfPages = numPages
        
        pageControll.currentPage = 0
    }
    
    private func downloadImageForSearchResult(searchResult:SearchResult,andPlaceOnButton button:UIButton){
    
        if let url = NSURL(string: searchResult.artworkURL60){
        
            let session =  NSURLSession.sharedSession()
            let downloadTask = session.downloadTaskWithURL(url) {
            
                [weak button] url, response, error in
                
                if error == nil ,let url = url,data = NSData(contentsOfURL: url),
                    image = UIImage(data: data){
                
                        dispatch_async(dispatch_get_main_queue()){
                            
                            if let button = button {
                            
                                button.setImage(image,forState:.Normal)
                            }
                        }
                }
            
            }
            
            downloadTask.resume()
            
            downloadTasks.append(downloadTask)
        }
    
    }
    
    
    @IBAction func pageChanged(sender:UIPageControl){
    
        UIView.animateWithDuration(0.3, delay: 0,options: .CurveEaseInOut,animations:{
            
            self.scrollView.contentOffset = CGPoint(x:self.scrollView.bounds.size.width * CGFloat(sender.currentPage),y: 0)
            
            },completion:nil
        )
        
        scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width * CGFloat(sender.currentPage), y: 0)
    
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LandscapeViewController:UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let width = scrollView.bounds.size.width
        
        let currentPage = Int((scrollView.contentOffset.x+width/2)/width)
        
        pageControll.currentPage = currentPage
    }

}
