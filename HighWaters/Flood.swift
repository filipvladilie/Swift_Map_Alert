//
//  Flood.swift
//  HighWaters
//
//  Created by Vlad Filip on 08.01.2023.
//

import Foundation

struct Flood: Codable {
  
  var latitude: Double
  var longitude: Double
  
  func toDictionary() -> [String: Any] {
    return ["latitude": self.latitude, "longitude": self.longitude]
  }
  
}
