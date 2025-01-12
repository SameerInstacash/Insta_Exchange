//
//  SpecificationValue.swift
//
//  Created by Sameer Khan on 12/01/25
//  Copyright (c) . All rights reserved.
//

import Foundation

class SpecificationValue: Codable {

  enum CodingKeys: String, CodingKey {
    case image
    case value
    case id
    case appCode
  }

  var image: String?
  var value: String?
  var id: String?
  var appCode: String?

  init (image: String?, value: String?, id: String?, appCode: String?) {
    self.image = image
    self.value = value
    self.id = id
    self.appCode = appCode
  }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    image = try container.decodeIfPresent(String.self, forKey: .image)
    value = try container.decodeIfPresent(String.self, forKey: .value)
    id = try container.decodeIfPresent(String.self, forKey: .id)
    appCode = try container.decodeIfPresent(String.self, forKey: .appCode)
  }

}
