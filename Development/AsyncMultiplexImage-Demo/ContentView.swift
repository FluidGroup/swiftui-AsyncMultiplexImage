//
//  ContentView.swift
//  AsyncMultiplexImage-Demo
//
//  Created by Muukii on 2022/09/13.
//

import SwiftUI

import AsyncMultiplexImage
import AsyncMultiplexImage_Nuke
import SwiftUI
import Nuke

struct _SlowDownloader: AsyncMultiplexImageDownloader {

  let pipeline: ImagePipeline
  
  init(pipeline: ImagePipeline) {
    self.pipeline = pipeline
  }
  
  func download(candidate: AsyncMultiplexImageCandidate, displaySize: CGSize) async throws -> UIImage {

    switch candidate.index {
    case 0:
      try? await Task.sleep(nanoseconds: 2_000_000_000)
    case 1:
      try? await Task.sleep(nanoseconds: 1_500_000_000)
    case 2:
      try? await Task.sleep(nanoseconds: 1_000_000_000)
    case 3:
      try? await Task.sleep(nanoseconds: 0_500_000_000)
    default:
      break
    }
    
    let response = try await pipeline.image(for: .init(urlRequest: candidate.urlRequest))
    return response
  }
  
}

struct ContentView: View {
  
  @State private var basePhotoURLString: String = "https://images.unsplash.com/photo-1492446845049-9c50cc313f00"
  
  var body: some View {
    VStack {
      AsyncMultiplexImage(
        multiplexImage: .init(identifier: basePhotoURLString, urls: buildURLs(basePhotoURLString)),
        downloader: _SlowDownloader(pipeline: .shared)
      ) { phase in
        switch phase {
        case .empty:
          Text("Loading")
        case .progress(let image):
          image
            .resizable()
            .scaledToFill()
        case .success(let image):
          image
            .resizable()
            .scaledToFill()
        case .failure(let error):
          Text("Error")
        }
      }
      
      HStack {
        Button("1") {
          basePhotoURLString = "https://images.unsplash.com/photo-1660668377331-da480e5339a0"
        }
        Button("2") {
          basePhotoURLString = "https://images.unsplash.com/photo-1658214764191-b002b517e9e5"
        }
        Button("3") {
          basePhotoURLString = "https://images.unsplash.com/photo-1587126396803-be14d33e49cf"
        }
      }
    }
    .padding()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

func buildURLs(_ baseURLString: String) -> [URL] {
    
  var components = URLComponents(string: baseURLString)!
  
  return [
    "",
    "w=100",
    "w=50",
    "w=10",
  ].map {
    
    components.query = $0
    
    return components.url!
    
  }
  
}
