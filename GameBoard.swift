import Observation

@Observable class Board: Codable {
    var objects: [BoardObject]
    var border: Int = 8 //last coordinate to be open space, always encodes for future compatibility but currently does not decode.
    
    init(objects: [BoardObject]) {
        self.objects = objects
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var objectsArray = try container.nestedUnkeyedContainer(forKey: .objects)
        var objects: [BoardObject] = []
        
        while !objectsArray.isAtEnd {
            let objectDecoder = try objectsArray.superDecoder()
            let obj = try BoardObject.decode(from: objectDecoder) // <-- Factory method
            objects.append(obj)
        }
        
        self.objects = objects
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(border, forKey: .border)
        var arrayContainer = container.nestedUnkeyedContainer(forKey: .objects)

        for object in objects {
            try object.encode(to: arrayContainer.superEncoder())
        }
    }

    private enum CodingKeys: String, CodingKey {
        case objects
        case border
        case borderWarning
    }
}
