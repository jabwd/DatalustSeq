//
//  SeqConfiguration.swift
//  
//
//  Created by Antwan van Houdt on 18/02/2021.
//

import Foundation

public struct SeqConfiguration: Codable {
  let ingestURL: URL
  let key: String

  public init(key: String, ingestURL: URL) {
    self.ingestURL = URL(string: "\(ingestURL)/api/events/raw?clef")!
    self.key = key
  }
}
