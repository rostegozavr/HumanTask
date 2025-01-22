import Foundation

public struct Contact: Decodable, Equatable {
    public struct Address: Decodable {
        public struct Geo: Decodable {
            public let lat: Double?
            public let lng: Double?

            public init(lat: Double? = nil, lng: Double? = nil) {
                self.lat = lat
                self.lng = lng
            }
            
            public init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                lat = Double(try values.decode(String.self, forKey: .lat))
                lng = Double(try values.decode(String.self, forKey: .lng))
            }
            
            enum CodingKeys: String, CodingKey {
                case lat
                case lng
            }
        }

        public let street: String?
        public let suite: String?
        public let city: String?
        public let zipcode: String?
        public let geo: Geo?

        public init(street: String? = nil, suite: String? = nil, city: String? = nil, zipcode: String? = nil, geo: Geo? = nil) {
            self.street = street
            self.suite = suite
            self.city = city
            self.zipcode = zipcode
            self.geo = geo
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case username
        case email
        case address
    }

    public let id: Int
    public let name: String?
    public let username: String?
    public let email: String?
    public let address: Address?
    
    public init(id: Int,
                name: String? = nil,
                username: String? = nil,
                email: String? = nil,
                address: Address? = nil) {
        self.id = id
        self.name = name
        self.username = username
        self.email = email
        self.address = address
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
