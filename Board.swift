import Observation

@Observable final class Board: Codable {
    var objects: [any BoardObject] {
        tanks + walls + oreDeposits
    }
    var tanks: [Tank] {
        didSet {
            await updateAppearanceMap()
        }
    }
    var walls: [Wall] {
        didSet {
            await updateAppearanceMap()
        }
    }
    var oreDeposits: [OreDeposit] {
        didSet {
            await updateAppearanceMap()
        }
    }
    var border: Int 
    
    var appearanceMap: [Coordinates: Appearance]
    
    var showBorderWarning: Bool = false
    
    init(tanks: [Tank], walls: [Wall], oreDeposits: [OreDeposit], border: Int) {
        self.tanks = tanks
        self.walls = walls
        self.oreDeposits = oreDeposits
        self.border = border
        appearanceMap = [:]
        Task {
            await updateAppearanceMap()
        }
    }
    
    private func updateAppearanceMap() async {
        appearanceMap = [:]
        for object in objects {
            appearanceMap[object.coordinates] = object.appearance
        }
    }
    
    var randomOpenPosition: Coordinates {
        while true {
            let position = Coordinates(x: Int.random(in: -border...border), y: Int.random(in: -border...border), rotation: .random)
            if !inBounds(at: position) {
                continue
            }
            if objects.contains(where: { $0.coordinates == position }) {
                continue
            }
            return position
        }
    }
    
    func inBounds(at position: Coordinates) -> Bool {
        if(abs(position.x) <= border) {
            if(abs(position.y) <= border) {
                return true
            }
        }
        return false
    }
}
