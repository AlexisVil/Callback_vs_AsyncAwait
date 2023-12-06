//
//  ViewModel.swift
//  Callback_vs_AsyncAwait
//
//  Created by Alexis Vilchis on 05/12/23.
//

import Foundation


final class ViewModel: ObservableObject {
    @Published var characterBasicInfo: CharacterBasicInfo = .empty
    
    func executeRequest() async {
        let urlRequest = URL(string: "https://rickandmortyapi.com/api/character/67")!
        let (data, _) = try! await URLSession.shared.data(from: urlRequest)
        let characterModel = try! JSONDecoder().decode(CharacterModel.self, from: data)
        
        let firstEpisodeURLRequest = URL(string: characterModel.episode.first!)!
        let (dataFirstEpisode, _ ) = try! await URLSession.shared.data(from: firstEpisodeURLRequest)
        let episodeModel = try! JSONDecoder().decode(EpisodeModel.self, from: dataFirstEpisode)
        
        let characterLocationURL = URL(string: characterModel.locationUrl)!
        let (dataLocation, _) = try! await URLSession.shared.data(from: characterLocationURL)
        let locationModel = try! JSONDecoder().decode(LocationModel.self, from: dataLocation)
        
        DispatchQueue.main.async {
            self.characterBasicInfo = .init(name: characterModel.name,
                                            image: URL(string: characterModel.image),
                                            firstEpisodeTitle: episodeModel.name,
                                            dimension: locationModel.dimension)
        }
    }
}
