//
//  Questions.swift
//
//  Created by Sameer Khan on 12/01/25
//  Copyright (c) . All rights reserved.
//

import Foundation

class Questions: Codable {

  enum CodingKeys: String, CodingKey {
    case viewType
    case conditionName
    case priorityOrder
    case appViewType
    case isInput
    case conditionSubHead
    case specificationId
    case appCodes
    case type
    case conditionId
    case specificationValue
    case specificationName
    case conditionValue
  }

  var viewType: String?
  var conditionName: String?
  var priorityOrder: String?
  var appViewType: String?
  var isInput: String?
  var conditionSubHead: String?
  var specificationId: String?
  var appCodes: [String]?
  var type: String?
  var conditionId: String?
  var specificationValue: [SpecificationValue]?
  var specificationName: String?
  var conditionValue: [ConditionValue]?

  init (viewType: String?, conditionName: String?, priorityOrder: String?, appViewType: String?, isInput: String?, conditionSubHead: String?, specificationId: String?, appCodes: [String]?, type: String?, conditionId: String?, specificationValue: [SpecificationValue]?, specificationName: String?, conditionValue: [ConditionValue]?) {
    self.viewType = viewType
    self.conditionName = conditionName
    self.priorityOrder = priorityOrder
    self.appViewType = appViewType
    self.isInput = isInput
    self.conditionSubHead = conditionSubHead
    self.specificationId = specificationId
    self.appCodes = appCodes
    self.type = type
    self.conditionId = conditionId
    self.specificationValue = specificationValue
    self.specificationName = specificationName
    self.conditionValue = conditionValue
  }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    viewType = try container.decodeIfPresent(String.self, forKey: .viewType)
    conditionName = try container.decodeIfPresent(String.self, forKey: .conditionName)
    priorityOrder = try container.decodeIfPresent(String.self, forKey: .priorityOrder)
    appViewType = try container.decodeIfPresent(String.self, forKey: .appViewType)
    isInput = try container.decodeIfPresent(String.self, forKey: .isInput)
    conditionSubHead = try container.decodeIfPresent(String.self, forKey: .conditionSubHead)
    specificationId = try container.decodeIfPresent(String.self, forKey: .specificationId)
    appCodes = try container.decodeIfPresent([String].self, forKey: .appCodes)
    type = try container.decodeIfPresent(String.self, forKey: .type)
    conditionId = try container.decodeIfPresent(String.self, forKey: .conditionId)
    specificationValue = try container.decodeIfPresent([SpecificationValue].self, forKey: .specificationValue)
    specificationName = try container.decodeIfPresent(String.self, forKey: .specificationName)
    conditionValue = try container.decodeIfPresent([ConditionValue].self, forKey: .conditionValue)
  }

}
