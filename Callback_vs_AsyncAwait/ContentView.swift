//
//  ContentView.swift
//  Callback_vs_AsyncAwait
//
//  Created by Alexis Vilchis on 05/12/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ViewModel()
    var body: some View {
        VStack {
            VStack {
                AsyncImage(url: viewModel.characterBasicInfo.image)
                Text(viewModel.characterBasicInfo.name)
                Text(viewModel.characterBasicInfo.firstEpisodeTitle)
                Text(viewModel.characterBasicInfo.dimension)
            }
        }
        .padding()
        .onAppear{
            Task {
                await viewModel.executeRequest()
            }
        }
    }
}

#Preview {
    ContentView()
}
