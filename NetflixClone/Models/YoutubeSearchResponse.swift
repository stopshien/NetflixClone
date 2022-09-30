//
//  YoutubeSearchResponse.swift
//  NetflixClone
//
//  Created by 沈庭鋒 on 2022/8/19.
//

import Foundation

/*
 items =     (
             {
         etag = OL8JrfCH0sXbMbZN9AYpBRGsqY0;
         id =             {
             kind = "youtube#video";
             videoId = IaLLGPkY54M;
         };
         kind = "youtube#searchResult";
     }
 */

struct YoutubeSearchResponse : Codable{
    let items : [VideosElement]
}

struct VideosElement : Codable{
    
    let id : IdVideoElement
    
}

struct IdVideoElement : Codable{
    
    let kind : String
    let videoId : String
    
}
