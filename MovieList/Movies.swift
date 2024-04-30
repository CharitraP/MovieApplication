//
//  Movies.swift
//  MovieList
//
//  Created by Charitra Prakash Yalimadannanavar on 4/21/24.
//

import Foundation

struct Movies{
     var movieId: String?
     var name: String
     var year: Date
     
     enum CodingKeys: String, CodingKey {
       case id
       case name = "language_name"
       case year
     }
}
