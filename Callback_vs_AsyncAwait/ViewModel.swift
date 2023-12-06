//
//  ViewModel.swift
//  Callback_vs_AsyncAwait
//
//  Created by Alexis Vilchis on 05/12/23.
//

import Foundation


struct CharacterModel: Decodable {
    let id: Int
    let name: String
    let image: String
    let episode: [String]
    let locationName: String
    let locationUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case image
        case episode
        case location
        case locationUrl = "url"
    }
    
    init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<CharacterModel.CodingKeys> = try decoder.container(keyedBy: CharacterModel.CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: CharacterModel.CodingKeys.id)
        self.name = try container.decode(String.self, forKey: CharacterModel.CodingKeys.name)
        self.image = try container.decode(String.self, forKey: CharacterModel.CodingKeys.image)
        self.episode = try container.decode([String].self, forKey: CharacterModel.CodingKeys.episode)
        let locationContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .location)
        self.locationName = try locationContainer.decode(String.self, forKey: .name)
        self.locationUrl = try locationContainer.decode(String.self, forKey: .locationUrl)
        
    }
}

struct EpisodeModel: Decodable {
    let id: Int
    let name: String
    let episode: String
}

struct LocationModel: Decodable {
    let id: Int
    let name: String
    let dimension: String
}

struct CharacterBasicInfo: Decodable {
    let name: String
    let image: URL?
    let firstEpisodeTitle: String
    let dimension: String
    
    static var empty: Self {
        .init(name: "", image: nil, firstEpisodeTitle: "", dimension: "")
    }
}

final class ViewModel: ObservableObject {
    
    @Published var characterBasicInfo: CharacterBasicInfo = .empty
    func executeRequest() {
        let urlRequest = URL(string: "https://rickandmortyapi.com/api/character/1")!
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let data = data {
                let characterModel = try! JSONDecoder().decode(CharacterModel.self, from: data)
                print(characterModel)
                
                let firstEpisodeURLRequest = URL(string: characterModel.episode.first!)!
                URLSession.shared.dataTask(with: firstEpisodeURLRequest) { episodeData, response, error in
                    if let episodeData = episodeData {
                        let episodeModel = try! JSONDecoder().decode(EpisodeModel.self, from: episodeData)
                        print("Episode Model: \(episodeModel)")
                        
                        let characterLocationURL = URL(string: characterModel.locationUrl)!
                        URLSession.shared.dataTask(with: characterLocationURL) {locationData, response, error in
                            if let locationData = locationData {
                                let locationModel = try! JSONDecoder().decode(LocationModel.self, from: locationData)
                                print("Location: \(locationModel)")
                                DispatchQueue.main.async {
                                    self.characterBasicInfo = .init(name: characterModel.name,
                                                                    image: URL(string: characterModel.image),
                                                                    firstEpisodeTitle: episodeModel.name,
                                                                    dimension: locationModel.dimension)
                                }
                            }
                        }.resume()
                    }
                }.resume()
            }
        }.resume()
    }
}
