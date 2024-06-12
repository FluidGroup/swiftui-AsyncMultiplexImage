import AsyncMultiplexImage
import Foundation
import Nuke
import SwiftUI

public actor AsyncMultiplexImageNukeDownloader: AsyncMultiplexImageDownloader {

  public let pipeline: ImagePipeline
  public let debugDelay: TimeInterval
  
  private var taskMap: [AsyncMultiplexImageCandidate : AsyncImageTask] = [:]

  public init(
    pipeline: ImagePipeline,
    debugDelay: TimeInterval
  ) {
    self.pipeline = pipeline
    self.debugDelay = debugDelay
  }

  public func download(
    candidate: AsyncMultiplexImageCandidate,
    displaySize: CGSize
  ) async throws -> UIImage {

    #if DEBUG

    try? await Task.sleep(nanoseconds: UInt64(debugDelay * 1_000_000_000))

    #endif

    let task = pipeline.imageTask(with: .init(
        urlRequest: candidate.urlRequest,
        processors: [
          ImageProcessors.Resize(
            size: displaySize,
            unit: .points,
            contentMode: .aspectFill,
            crop: false,
            upscale: false
          )
        ]
      )
    )
    
    taskMap[candidate] = task
    
    let result = try await task.image
    
    taskMap.removeValue(forKey: candidate)
    
    return result
  }
  
  public func deprioritize(candidates: some Sequence<AsyncMultiplexImageCandidate>) {
    for candidate in candidates {
      taskMap[candidate]?.priority = .low
    }    
  }  
  
}
