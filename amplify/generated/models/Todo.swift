// swiftlint:disable all
import Amplify
import Foundation

public struct Todo: Model {
  public let id: String
  public var username: String
  public var email: String
  public var description: String?
  public var imageURL: String?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      username: String,
      email: String,
      description: String? = nil,
      imageURL: String? = nil) {
    self.init(id: id,
      username: username,
      email: email,
      description: description,
      imageURL: imageURL,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      username: String,
      email: String,
      description: String? = nil,
      imageURL: String? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.username = username
      self.email = email
      self.description = description
      self.imageURL = imageURL
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}
