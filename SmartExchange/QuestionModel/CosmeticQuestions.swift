//
//  CosmeticQuestions.swift
//
//  Created by Sameer Khan on 12/01/25
//  Copyright (c) . All rights reserved.
//

import Foundation

class CosmeticQuestions: Codable {

  enum CodingKeys: String, CodingKey {
    case timeStamp
    case msg
    case status
  }

  var timeStamp: String?
  var msg: Msg?
  var status: String?

  init (timeStamp: String?, msg: Msg?, status: String?) {
    self.timeStamp = timeStamp
    self.msg = msg
    self.status = status
  }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    timeStamp = try container.decodeIfPresent(String.self, forKey: .timeStamp)
    msg = try container.decodeIfPresent(Msg.self, forKey: .msg)
    status = try container.decodeIfPresent(String.self, forKey: .status)
  }

}
