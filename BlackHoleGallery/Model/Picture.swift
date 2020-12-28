import Foundation
import UIKit

class Picture: Codable {
    
    var name: String
    var comment: String
    var like: Int
    
    convenience init() {
        self.init("", "", 0)
    }
    
    convenience init(_ name: String) {
        self.init(name, "", 0)
    }
    
    init(_ name: String, _ comment: String, _ like: Int) {
        self.name = name
        self.comment = comment
        self.like = like
    }
    
    public enum CodingKeys: String, CodingKey {
        case name, comment, like
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try container.decode(String.self, forKey: .name)
        self.comment = try container.decode(String.self, forKey: .comment)
        self.like = try container.decode(Int.self, forKey: .like)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.name, forKey: .name)
        try container.encode(self.comment, forKey: .comment)
        try container.encode(self.like, forKey: .like)
    }
    
}
