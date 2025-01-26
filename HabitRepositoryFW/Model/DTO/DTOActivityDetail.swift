//
//  DTOActivityDetail.swift
//  HabitMePrototype
//
//  Created by Boyce Estes on 1/25/25.
//


// This is just to give me a nice
// simple interface that I can use
// whenever I am seeding the Details
struct DTOActivityDetail: Decodable {
    
    let id: String
    let name: String
    let availableUnits: String?
    var isArchived: Bool
    let creationDate: Date
    let calculationType: ActivityDetailCalculationType?
    let valueType: ActivityDetailType
    
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case availableUnits
        case isArchived
        case creationDate
        case calculationType
        case valueType
    }
    
    
    init(from decoder: any Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = UUID().uuidString
        self.name = try container.decode(String.self, forKey: .name)
        self.availableUnits = try container.decodeIfPresent(String.self, forKey: .availableUnits)
        self.isArchived = false
        self.creationDate = Date()
        self.calculationType = try container.decodeIfPresent(ActivityDetailCalculationType.self, forKey: .calculationType)
        self.valueType = try container.decode(ActivityDetailType.self, forKey: .valueType)
    }
}
