//
//  MovieResponse.swift
//  MovieList
//
//  Created by Charitra Prakash Yalimadannanavar on 2/27/24.
//

import Foundation
struct MovieResponse: Decodable {
    var dates : Dates?
    var page : Int
    var results : [Movie]
}

struct Dates: Decodable {
    let maximum: String
    let minimum: String
}
