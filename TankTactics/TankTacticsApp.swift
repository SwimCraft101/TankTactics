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
    
    @State var printerCalibration: PrinterCalibration = PrinterCalibration(verticalOffset: 0.12, horizontalOffset: 0.23, rotation: Angle(degrees: -0.32))
    
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
                        TabView {
                            VStack {
                                Button("Enact Turn") {
                                    game.executeTurn()
                                    if game.gameDay.isDeadDay {
                                        saveTurnToPDF(players: (game.board.objects.filter({ $0 is Player }) as! [Player]).filter({ !$0.playerInfo.doVirtualDelivery }), messages: game.messages.filter({ message in
                                            !(game.board.objects.first { $0.uuid == message.recipient } as! Player).playerInfo.doVirtualDelivery }), eventCards: game.eventCardsToPrint, notes: game.notes, printerCalibration: printerCalibration)
                                    } else {
                                        saveTurnToPDF(players: (game.board.objects.filter({ $0 is Tank }) as! [Player]).filter({ !$0.playerInfo.doVirtualDelivery }), messages: game.messages.filter({ message in
                                            !(game.board.objects.first { $0.uuid == message.recipient } as! Player).playerInfo.doVirtualDelivery }), eventCards: game.eventCardsToPrint, notes: game.notes, printerCalibration: printerCalibration)
                                    }
                                    for virtualPlayer in game.board.objects.filter({
                                        if ($0 is Player && game.gameDay.isDeadDay) || ($0 is Tank) {
                                            if ($0 as! Player).playerInfo.doVirtualDelivery {
                                                return true
                                            }
                                        }
                                        return false
                                    }) {
                                        var date = Date.now.addingTimeInterval(57600)
                                        if date.formatted(
                                            Date.FormatStyle()
                                                .year(.omitted)
                                                .month(.omitted)
                                                .day(.omitted)
                                                .hour(.omitted)
                                                .minute(.omitted)
                                                .timeZone(.omitted)
                                                .era(.omitted)
                                                .dayOfYear(.omitted)
                                                .weekday(.wide)
                                                .week(.omitted)
                                        ) == "Saturday" {
                                            date.addTimeInterval(86400)
                                        }
                                        if date.formatted(
                                            Date.FormatStyle()
                                                .year(.omitted)
                                                .month(.omitted)
                                                .day(.omitted)
                                                .hour(.omitted)
                                                .minute(.omitted)
                                                .timeZone(.omitted)
                                                .era(.omitted)
                                                .dayOfYear(.omitted)
                                                .weekday(.wide)
                                                .week(.omitted)
                                        ) == "Sunday" {
                                            date.addTimeInterval(86400)
                                        }
                                        NSWorkspace.shared.open(URL(string: """
                                        mailto:\((virtualPlayer as! Player).playerInfo.virtualDelivery ?? " NO EMAIL ADDRESS WAS FOUND ")?\
                                        subject=Tank Tactics: \(date.formatted(date: .complete, time: .omitted))&\
                                        body=
                                        """)!)
                                        if virtualPlayer is Tank {
                                            createAndSavePDF(from: [AnyView(VirtualStatusCard(tank: virtualPlayer as! Tank))], fileName: "Virtual Status Card for \((virtualPlayer as! Player).playerInfo.fullName)", pageSize: CGSize(width: inch(12), height: inch(8)))
                                        } else {
                                            createAndSavePDF(from: [AnyView(DeadVirtualStatusCard(tank: virtualPlayer as! DeadTank))], fileName: "Virtual Status Card for \((virtualPlayer as! Player).playerInfo.fullName)", pageSize: CGSize(width: inch(12), height: inch(8)))
                                        }
                                    }
                                    promptToSaveEncodedFile(game, fileName: "game")
                                    game.notes.removeAll()
                                    game.eventCardsToPrint.removeAll()
                                    game.actions.removeAll()
                                    game.messages.removeAll()
                                }
                                
                                    Button("Print Turn Without Enacting") {
                                        if game.gameDay.isDeadDay {
                                            saveTurnToPDF(players: (game.board.objects.filter({ $0 is Player }) as! [Player]).filter({ !$0.playerInfo.doVirtualDelivery }), messages: game.messages.filter({ message in
                                                !(game.board.objects.first { $0.uuid == message.recipient } as! Player).playerInfo.doVirtualDelivery }), eventCards: game.eventCardsToPrint, notes: game.notes, printerCalibration: printerCalibration)
                                        } else {
                                            saveTurnToPDF(players: (game.board.objects.filter({ $0 is Tank }) as! [Player]).filter({ !$0.playerInfo.doVirtualDelivery }), messages: game.messages.filter({ message in
                                                !(game.board.objects.first { $0.uuid == message.recipient } as! Player).playerInfo.doVirtualDelivery }), eventCards: game.eventCardsToPrint, notes: game.notes, printerCalibration: printerCalibration)
                                        }
                                        for virtualPlayer in game.board.objects.filter({
                                            if ($0 is Player && game.gameDay.isDeadDay) || ($0 is Tank) {
                                                if ($0 as! Player).playerInfo.doVirtualDelivery {
                                                    return true
                                                }
                                            }
                                            return false
                                        }) {
                                            var date = Date.now.addingTimeInterval(57600)
                                            if date.formatted(
                                                Date.FormatStyle()
                                                    .year(.omitted)
                                                    .month(.omitted)
                                                    .day(.omitted)
                                                    .hour(.omitted)
                                                    .minute(.omitted)
                                                    .timeZone(.omitted)
                                                    .era(.omitted)
                                                    .dayOfYear(.omitted)
                                                    .weekday(.wide)
                                                    .week(.omitted)
                                            ) == "Saturday" {
                                                date.addTimeInterval(86400)
                                            }
                                            if date.formatted(
                                                Date.FormatStyle()
                                                    .year(.omitted)
                                                    .month(.omitted)
                                                    .day(.omitted)
                                                    .hour(.omitted)
                                                    .minute(.omitted)
                                                    .timeZone(.omitted)
                                                    .era(.omitted)
                                                    .dayOfYear(.omitted)
                                                    .weekday(.wide)
                                                    .week(.omitted)
                                            ) == "Sunday" {
                                                date.addTimeInterval(86400)
                                            }
                                            NSWorkspace.shared.open(URL(string: """
                                            mailto:\((virtualPlayer as! Player).playerInfo.virtualDelivery ?? " NO EMAIL ADDRESS WAS FOUND ")?\
                                            subject=Tank Tactics: \(date.formatted(date: .complete, time: .omitted))&\
                                            body=
                                            """)!)
                                            if virtualPlayer is Tank {
                                                createAndSavePDF(from: [AnyView(VirtualStatusCard(tank: virtualPlayer as! Tank))], fileName: "Virtual Status Card for \((virtualPlayer as! Player).playerInfo.fullName)", pageSize: CGSize(width: inch(12), height: inch(8)))
                                            } else {
                                                createAndSavePDF(from: [AnyView(DeadVirtualStatusCard(tank: virtualPlayer as! DeadTank))], fileName: "Virtual Status Card for \((virtualPlayer as! Player).playerInfo.fullName)", pageSize: CGSize(width: inch(12), height: inch(8)))
                                            }
                                        }
                                    }
                                Button("Print Full Board") {
                                    createAndSavePDF(from: [
                                        AnyView(
                                            SquareViewport(coordinates: Coordinates(x: 0, y: 0, level: level, rotation: .north), viewRenderSize: game.board.border + 1, highDetailSightRange: 1000000, lowDetailSightRange: 1000000, radarRange: 1000000, accessibilitySettings: AccessibilitySettings(), selectedObject: $selectedObject).frame(width: inch(8), height: inch(8))
                                        )
                                    ], fileName: "board")
                                }
                                Button("Save Game File") {
                                    uiBannerMessage = "Saving game file..."
                                    promptToSaveEncodedFile(game, fileName: "game")
                                    uiBannerMessage = ""
                                }
                                HStack {
                                    Button("Print Alignment Compensation") {
                                        createAndSavePDF(from: [
                                            AnyView(
                                                Grid(alignment: .center, horizontalSpacing: 0, verticalSpacing: 0) {
                                                    Rectangle()
                                                        .fill(.green)
                                                        .frame(height: inch(0.01))
                                                    ForEach(0...10, id: \.self) { _ in
                                                        Rectangle()
                                                            .fill(.black)
                                                            .frame(height: inch(0.01))
                                                        GridRow {
                                                            ForEach(0...10, id: \.self) { _ in
                                                                Rectangle()
                                                                    .fill(.black)
                                                                    .frame(width: inch(0.01))
                                                                Spacer()
                                                                Spacer()
                                                                Spacer()
                                                                Spacer()
                                                            }
                                                            Rectangle()
                                                                .fill(.black)
                                                                .frame(width: inch(0.01))
                                                        }
                                                    }
                                                    Rectangle()
                                                        .fill(.black)
                                                        .frame(height: inch(0.01))
                                                }
                                                    .frame(width: inch(10), height: inch(8))
                                                    .frame(width: inch(11), height: inch(8.5), alignment: .center)
                                            ),
                                            AnyView(
                                                Grid(alignment: .center, horizontalSpacing: 0, verticalSpacing: 0) {
                                                    Rectangle()
                                                        .fill(.green)
                                                        .frame(height: inch(0.01))
                                                    ForEach(0...10, id: \.self) { _ in
                                                        Rectangle()
                                                            .fill(.blue)
                                                            .frame(height: inch(0.01))
                                                        GridRow {
                                                            ForEach(0...10, id: \.self) { _ in
                                                                Rectangle()
                                                                    .fill(.blue)
                                                                    .frame(width: inch(0.01))
                                                                Spacer()
                                                                Spacer()
                                                                Spacer()
                                                                Spacer()
                                                            }
                                                            Rectangle()
                                                                .fill(.blue)
                                                                .frame(width: inch(0.01))
                                                        }
                                                    }
                                                    Rectangle()
                                                        .fill(.blue)
                                                        .frame(height: inch(0.01))
                                                }
                                                    .frame(width: inch(10), height: inch(8))
                                                    .compensateForPrinterAlignment(printerCalibration)
                                                    .frame(width: inch(11), height: inch(8.5), alignment: .center)
                                            )
                                        ], fileName: "Alignment Calibration")
                                    }
                                    TextField("Horizontal Offset", value: Binding<Double>(
                                        get: {
                                            Double(printerCalibration.horizontalOffset)
                                        },
                                        set: {
                                            printerCalibration.horizontalOffset = CGFloat(Double($0))
                                        }),
                                        format: .number)
                                    TextField("Vertical Offset", value: Binding<Double>(
                                        get: {
                                            Double(printerCalibration.verticalOffset)
                                        },
                                        set: {
                                            printerCalibration.verticalOffset = CGFloat(Double($0))
                                        }),
                                        format: .number)
                                    TextField("Rotaion", value: Binding<Double>(
                                        get: {
                                            Double(printerCalibration.rotation.degrees)
                                        },
                                        set: {
                                            printerCalibration.rotation = Angle(degrees: $0)
                                        }),
                                        format: .number)
                                    
                                }
                                HStack {
                                    Button("Give all players Tutorial Modules") {
                                        for tank in game.board.objects.filter({ $0 is Tank }) {
                                            (tank as! Tank).modules.insert(TutorialModule(tankId: tank.uuid), at: 0)
                                        }
                                        Tank.bindModules()
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
                                    Text("Living Module Monday").tag(GameDay.mondayNormal)
                                    Text("Dead Treacherous Tuesday").tag(GameDay.deadTuesday)
                                    Text("Living Wheel Wednesday").tag(GameDay.wednesdayNormal)
                                    Text("Dead Thrifty Thursday").tag(GameDay.deadThursday)
                                    Text("Living Firearm Friday").tag(GameDay.fridayNormal)
                                    Text("Dead Module Monday").tag(GameDay.deadMonday)
                                    Text("Living Treacherous Tuesday").tag(GameDay.tuesdayNormal)
                                    Text("Dead Wheel Wednesday").tag(GameDay.deadWednesday)
                                    Text("Living Thrifty Thursday").tag(GameDay.thursdayNormal)
                                    Text("Dead Firearm Friday").tag(GameDay.deadFriday)
                                }
                                Picker("Next Game Day", selection: $game.nextGameDay) {
                                    Text("Living Module Monday").tag(GameDay.mondayNormal)
                                    Text("Dead Treacherous Tuesday").tag(GameDay.deadTuesday)
                                    Text("Living Wheel Wednesday").tag(GameDay.wednesdayNormal)
                                    Text("Dead Thrifty Thursday").tag(GameDay.deadThursday)
                                    Text("Living Firearm Friday").tag(GameDay.fridayNormal)
                                    Text("Dead Module Monday").tag(GameDay.deadMonday)
                                    Text("Living Treacherous Tuesday").tag(GameDay.tuesdayNormal)
                                    Text("Dead Wheel Wednesday").tag(GameDay.deadWednesday)
                                    Text("Living Thrifty Thursday").tag(GameDay.thursdayNormal)
                                    Text("Dead Firearm Friday").tag(GameDay.deadFriday)
                                }
                                Spacer()
                                
                            }
                            .tabItem {
                                Label("Game", systemImage: "globe")
                            }
                            Inspector(object: $selectedObject)
                                .tabItem {
                                    Label("Inspector", systemImage: "info")
                                }
                            ActionList()
                                .tabItem {
                                    Label("Actions", systemImage: "righttriangle")
                                }
                            MessageList()
                                .tabItem {
                                    Label("Messages", systemImage: "message")
                                }
                            TurnNotesList()
                                .tabItem {
                                    Label("Notes", systemImage: "pencil.and.list.clipboard")
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

extension Color: @retroactive Decodable {}
extension Color: @retroactive Encodable {}
extension Color {
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
