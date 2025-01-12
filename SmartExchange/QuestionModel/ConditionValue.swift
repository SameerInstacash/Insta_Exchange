//
//  ConditionValue.swift
//
//  Created by Sameer Khan on 12/01/25
//  Copyright (c) . All rights reserved.
//

import Foundation

class ConditionValue: Codable {

  enum CodingKeys: String, CodingKey {
    case image
    case appCode
    case value
    case id
  }

  var image: String?
  var appCode: String?
  var value: String?
  var id: String?

  init (image: String?, appCode: String?, value: String?, id: String?) {
    self.image = image
    self.appCode = appCode
    self.value = value
    self.id = id
  }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    image = try container.decodeIfPresent(String.self, forKey: .image)
    appCode = try container.decodeIfPresent(String.self, forKey: .appCode)
    value = try container.decodeIfPresent(String.self, forKey: .value)
    id = try container.decodeIfPresent(String.self, forKey: .id)
  }

}
