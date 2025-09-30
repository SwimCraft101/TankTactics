//
//  TankTacticsApp.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 5/15/24.
//

import SwiftUI
import AppKit
import Foundation

@Observable
final class AppState {
    static var shared: AppState = .init()
    
    var fileIsOpen: Bool = false
    
    required init() {
        self.fileIsOpen = false
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let loadedGame = promptForDecodedFile(ofType: Game.self) {
            Game.shared = loadedGame
            AppState.shared.fileIsOpen = true
        } else {
            fatalError("File could not decode")
        }
    }
}

@main struct TankTacticsApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @Bindable var appState: AppState = AppState.shared
    
    var body: some Scene {
        Window("Tank Tactics IV", id: "Tank Tactics IV") {
            if appState.fileIsOpen {
                ContentView()
                    .environment(Game.shared)
            } else {
                EmptyView()
            }
        }
    }
}

struct ContentView: View {
    @State var levelDisplayed: Int = 0
    @State var showBorderWarning: Bool = false
    @State var uiBannerMessage: String = ""
    
    @State var selectedObject: BoardObject = Game.shared.board.objects.first!
    
    @Bindable var game = Game.shared
    
    var body: some View {
        VStack {
            Text(uiBannerMessage)
                .font(.title)
            GeometryReader { geometry in
                HStack {
                    //MARK: Dead Tanks List
                    let level = levelDisplayed
                    ZStack {
                        Color.white
                        SquareViewport(coordinates: Coordinates(x: 0, y: 0, level: level, rotation: .north), viewRenderSize: game.board.border + 1, highDetailSightRange: 1000000, lowDetailSightRange: 1000000, radarRange: 1000000, accessibilitySettings: AccessibilitySettings(), selectedObject: $selectedObject)
                            .frame(width: max(min(geometry.size.height, geometry.size.width), 300), height: max(min(geometry.size.height, geometry.size.width), 300), alignment: .center)
                    }
                    VStack {
                        HStack {
                            VStack {
                                Button("Enact Turn") {
                                    game.executeTurn()
                                    for virtualTank in game.board.objects.filter({
                                        if $0 is Tank {
                                            if ($0 as! Tank).playerInfo.doVirtualDelivery {
                                                return true
                                            }
                                        }
                                        return false
                                    }) {
                                        NSWorkspace.shared.open(URL(string: "mailto:\((virtualTank as! Tank).playerInfo.virtualDelivery ?? " NO EMAIL ADDRESS WAS FOUND ")?subject=Tank Tactics: \(Date.now.addingTimeInterval(57600).formatted(date: .complete, time: .omitted))")!) //MARK: rework this?
                                        createAndSavePDF(from: [AnyView(VirtualStatusCard(tank: virtualTank as! Tank))], fileName: "Virtual Status Card for \((virtualTank as! Tank).playerInfo.fullName)", pageSize: CGSize(width: inch(12), height: inch(8)))
                                    }
                                }
                                Button("Print Full Board") {
                                    createAndSavePDF(from: [AnyView(SquareViewport(coordinates: Coordinates(x: 0, y: 0, level: level, rotation: .north), viewRenderSize: game.board.border + 1, highDetailSightRange: 1000000, lowDetailSightRange: 1000000, radarRange: 1000000, accessibilitySettings: AccessibilitySettings(), selectedObject: $selectedObject).frame(width: inch(8), height: inch(8)))], fileName: "board")
                                }
                                Button("Save Game File") {
                                    uiBannerMessage = "Saving game file..."
                                    promptToSaveEncodedFile(game, fileName: "game")
                                    uiBannerMessage = ""
                                }
                                HStack {
                                    Button("Give all players Tutorial Modules") {
                                        for tank in game.board.objects.filter({ $0 is Tank }) {
                                            (tank as! Tank).modules.insert(TutorialModule(isWeekTwo: false), at: 0)
                                        }
                                        Tank.bindModules()
                                    }
                                    Button("Set tutorial Modules to week 2") {
                                        for object in game.board.objects {
                                            if let tank = object as? Tank {
                                                for module in tank.modules {
                                                    if let tutorial = module as? TutorialModule {
                                                        tutorial.isWeekTwo = true
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    Button("Remove Tutorial Modules") {
                                        for tank in game.board.objects.filter({ $0 is Tank }) {
                                            (tank as! Tank).modules.removeAll { $0 is TutorialModule }
                                        }
                                    }
                                }
                                Stepper("Level Displayed", value: $levelDisplayed)
                                HStack {
                                    Stepper("Border", value: $game.board.border)
                                    Toggle("Show Border Warning", isOn: $game.board.showBorderWarning)
                                }
                                Picker("Game Day", selection: $game.gameDay) {
                                    Text("Module Monday").tag(GameDay.monday)
                                    Text("Treacherous Tuesday").tag(GameDay.tuesday)
                                    Text("Wheel Wednesday").tag(GameDay.wednesday)
                                    Text("Thrifty Thursday").tag(GameDay.thursday)
                                    Text("Firearm Friday").tag(GameDay.friday)
                                }
                                Spacer()
                                
                            }
                            ActionList()
                        }
                        Inspector(object: $selectedObject)
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
