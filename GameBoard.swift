import Observation

@Observable final class Board: Codable {
    var objects: [BoardObject]
    var border: Int //last coordinate to be open space, always encodes for future compatibility but currently does not decode.
    
    var showBorderWarning: Bool = false
    
    init(objects: [BoardObject], border: Int) {
        self.objects = objects
        self.border = border
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.border = try container.decode(Int.self, forKey: .border)
        self.showBorderWarning = try container.decode(Bool.self, forKey: .borderWarning)
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
        try container.encode(showBorderWarning, forKey: .borderWarning)
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
