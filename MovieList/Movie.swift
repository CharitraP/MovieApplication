//
//  Movie.swift
//  MovieList
//
//  Created by Charitra Prakash Yalimadannanavar on 2/24/24.
//

import Foundation

struct Movie: Identifiable, Codable {
    var backdrop_path: String?
    var id: Int
    var overview: String?
    var poster_path: String?
    var release_date: String?
    var runtime: Int?
    var title: String?
    var vote_average: Double?
    var vote_count : Int?
    var genres: [Genre]?

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(backdrop_path, forKey: .backdrop_path)
        try container.encode(id, forKey: .id)
        try container.encode(overview, forKey: .overview)
        try container.encode(poster_path, forKey: .poster_path)
        try container.encode(release_date, forKey: .release_date)
        try container.encode(runtime, forKey: .runtime)
        try container.encode(title, forKey: .title)
        try container.encode(vote_average, forKey: .vote_average)
        try container.encode(vote_count, forKey: .vote_count)
        try container.encode(genres, forKey: .genres)
    }

    private enum CodingKeys: String, CodingKey {
        case backdrop_path
        case id
        case overview
        case poster_path
        case release_date
        case runtime
        case title
        case vote_average
        case vote_count
        case genres
    }
}
