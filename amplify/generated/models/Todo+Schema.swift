// swiftlint:disable all
import Amplify
import Foundation

extension Todo {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case username
    case email
    case description
    case imageURL
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
    public static let schema = defineSchema { model in
        let todo = Todo.keys
        
        model.pluralName = "Todos"
        
        model.fields(
            .id(),
            .field(todo.username, is: .required, ofType: .string),
            .field(todo.email, is: .required, ofType: .string),
            .field(todo.description, is: .optional, ofType: .string),
            .field(todo.imageURL, is: .optional, ofType: .string),
            .field(todo.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
            .field(todo.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
        )
    }
}
