//
//  Movie.swift
//  NetflixClone
//
//  Created by 潘立婷 on 2022/8/5.
//

import Foundation

struct TrendingTitleResponse: Codable {
    let results : [Title]
}

struct Title : Codable{
    
    let id : Int
    let media_type : String?
    let original_language : String?
    let original_title : String?
    let overview : String?
    let poster_path : String?
    let release_date : String?
    let vote_average : Double
    let vote_count : Int
    
}


