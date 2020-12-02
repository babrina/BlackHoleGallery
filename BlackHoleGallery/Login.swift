import Foundation
import UIKit

class Login: Codable {
    var name: String
    var pincode: Int


init(name: String, pincode: Int) {
    self.name = name
    self.pincode = pincode
}
    
    
    public enum CodingKeys: String, CodingKey {
        case name, pincode
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try container.decode(String.self, forKey: .name)
        self.pincode = try container.decode(Int.self, forKey: .pincode)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.name, forKey: .name)
        try container.encode(self.pincode, forKey: .pincode)
    }
    
}
