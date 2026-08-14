import Observation

@Observable final class Board: Codable {
    var objects: [any BoardObject] {
        return tanks + walls + oreDeposits
    }
    var tanks: [Tank]
    var walls: [Wall]
    var oreDeposits: [OreDeposit]
    var border: Int
    
    var showBorderWarning: Bool = false
    
    init(tanks: [Tank], walls: [Wall], oreDeposits: [OreDeposit], border: Int) {
        self.tanks = tanks
        self.walls = walls
        self.oreDeposits = oreDeposits
        self.border = border
    }
}
