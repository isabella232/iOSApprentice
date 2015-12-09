//
//  SearchResult.swift
//  StoreSearch
//
//  Created by Jay on 15/12/1.
//  Copyright © 2015年 look4us. All rights reserved.
//

import Foundation

class SearchResult {
    
    var name = ""
    
    var artistName = ""
    
    var artworkURL60 = ""
    
    var artworkURL100 = ""
    
    var storeURL = ""
    
    var kind = ""
    
    var currency = ""
    
    var price = 0.0
    
    var genre = ""
    
    
    func kindForDisplay()->String {
        
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

func < (lhs:SearchResult,rhs:SearchResult) -> Bool {

    return lhs.name.localizedStandardCompare(rhs.name) == .OrderedAscending

}

