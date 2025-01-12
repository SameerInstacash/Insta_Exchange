//
//  Msg.swift
//
//  Created by Sameer Khan on 12/01/25
//  Copyright (c) . All rights reserved.
//

import Foundation

class Msg: Codable {

  enum CodingKeys: String, CodingKey {
    case basePrice
    case id
    case image
    case questions
    case name
  }

  var basePrice: String?
  var id: String?
  var image: String?
  var questions: [Questions]?
  var name: String?

  init (basePrice: String?, id: String?, image: String?, questions: [Questions]?, name: String?) {
    self.basePrice = basePrice
    self.id = id
    self.image = image
    self.questions = questions
    self.name = name
  }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    basePrice = try container.decodeIfPresent(String.self, forKey: .basePrice)
    id = try container.decodeIfPresent(String.self, forKey: .id)
    image = try container.decodeIfPresent(String.self, forKey: .image)
    questions = try container.decodeIfPresent([Questions].self, forKey: .questions)
    name = try container.decodeIfPresent(String.self, forKey: .name)
  }

}
