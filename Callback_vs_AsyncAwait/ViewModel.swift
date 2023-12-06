//
//  ViewModel.swift
//  Callback_vs_AsyncAwait
//
//  Created by Alexis Vilchis on 05/12/23.
//

import Foundation


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
