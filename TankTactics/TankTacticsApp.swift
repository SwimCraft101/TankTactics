//
//  TankTacticsApp.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 5/15/24.
//

import SwiftUI
import AppKit
import Foundation

@main struct TankTacticsApp: App {
    @State var levelDisplayed: Int = 0
    @State var showBorderWarning: Bool = false
    @State var uiBannerMessage: String = ""
    
    var DeadTanks: [DeadTank] = {
        var result: [DeadTank] = []
        for object in Game.shared.board.objects.filter({ $0 is DeadTank }) {
            result.append(object as! DeadTank)
        }
        return result
    }()
    var body: some Scene {
        WindowGroup {
            VStack {
                Text(uiBannerMessage)
                    .font(.title)
                GeometryReader { geometry in
                    HStack {
                        //MARK: Dead Tanks List
                        let level = levelDisplayed
                        ZStack {
                            Color.white
                            SquareViewport(coordinates: Coordinates(x: 0, y: 0, level: level), viewRenderSize: Game.shared.board.border + 1, highDetailSightRange: 1000000, lowDetailSightRange: 1000000, radarRange: 1000000, showBorderWarning: showBorderWarning, accessibilitySettings: AccessibilitySettings())
                                
                                .frame(width: max(min(geometry.size.height, geometry.size.width), 300), height: max(min(geometry.size.height, geometry.size.width), 300), alignment: .center)
                        }
                        VStack {
                            HStack {
                                Spacer()
                                VStack {
                                    Button("Print Turn") {
                                        Tank.bindModules()
                                        saveTurnToPDF(players: Game.shared.board.objects.filter{ $0 is Tank } as! [Tank], messages: [], doAlignmentCompensation: true)
                                        for virtualTank in Game.shared.board.objects.filter({
                                            if $0 is Tank {
                                                if ($0 as! Tank).doVirtualDelivery {
                                                    return true
                                                }
                                            }
                                            return false
                                        }) {
                                            NSWorkspace.shared.open(URL(string: "mailto:\((virtualTank as! Tank).playerInfo.virtualDelivery ?? " NO EMAIL ADDRESS WAS FOUND ")?subject=Tank Tactics: \(Date.now.addingTimeInterval(57600).formatted(date: .complete, time: .omitted))&body=no body text here (:")!) //MARK: rework this?
                                            createAndSavePDF(from: [AnyView(VirtualStatusCard(tank: virtualTank as! Tank, showBorderWarning: showBorderWarning))], fileName: "Virtual Status Card for \((virtualTank as! Tank).playerInfo.firstName) \((virtualTank as! Tank).playerInfo.lastName)")
                                        }
                                    }
                                    Button("Print Full Board") {
                                        createAndSavePDF(from: [AnyView(SquareViewport(coordinates: Coordinates(x: 0, y: 0, level: level), viewRenderSize: Game.shared.board.border + 1, highDetailSightRange: 1000000, lowDetailSightRange: 1000000, radarRange: 1000000, showBorderWarning: showBorderWarning, accessibilitySettings: AccessibilitySettings()).frame(width: inch(8), height: inch(8)))], fileName: "board")
                                    }
                                    Button("Open Game File") {
                                        uiBannerMessage = "Opening saved game file..."
                                            if let loadedGame = promptForDecodedFile(ofType: Game.self) {
                                                Game.shared = loadedGame
                                            } else {
                                                fatalError("File could not decode")
                                            }
                                        uiBannerMessage = "Done"
                                        uiBannerMessage = ""
                                    }
                                    Button("Save Game File") {
                                        uiBannerMessage = "Saving game file..."
                                        promptToSaveEncodedFile(Game.shared, fileName: "game.tanktactics")
                                        uiBannerMessage = ""
                                    }
                                    Stepper("Level Displayed", value: $levelDisplayed)
                                    Toggle("Show Border Warning", isOn: $showBorderWarning)
                                    Spacer()
                                    Inspector(Game.shared.board.objects.first!)
                                        
                                }
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
    }
}

precedencegroup ExponentiationPrecedence {
    higherThan: MultiplicationPrecedence
    associativity: right
}

infix operator ** : ExponentiationPrecedence

func ** (lhs: Double, rhs: Double) -> Double {
    return pow(lhs, rhs)
}

extension Color: Codable {
    private enum CodingKeys: String, CodingKey {
        case red, green, blue, alpha
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let red = try container.decode(Double.self, forKey: .red)
        let green = try container.decode(Double.self, forKey: .green)
        let blue = try container.decode(Double.self, forKey: .blue)
        let alpha = try container.decode(Double.self, forKey: .alpha)
        self = Color(red: red, green: green, blue: blue, opacity: alpha)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        #if os(iOS)
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        #else
        let nsColor = NSColor(self)
        let color = nsColor.usingColorSpace(.deviceRGB) ?? nsColor
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        #endif
        
        try container.encode(Double(r), forKey: .red)
        try container.encode(Double(g), forKey: .green)
        try container.encode(Double(b), forKey: .blue)
        try container.encode(Double(a), forKey: .alpha)
    }
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
