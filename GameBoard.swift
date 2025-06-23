import Observation
import SwiftUI

@Observable class Board {
    var objects: [any BoardObject]
    
    init(objects: [any BoardObject]) {
        self.objects = objects
    }
}
