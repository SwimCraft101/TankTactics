//
//  TankTacticsApp.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 5/15/24.
//

import SwiftUI
import AppKit
import Foundation

@main
struct TankTacticsApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: { Game() }) { configuration in
            ContentView(game: configuration.document, selectedObject: nil)
        }
    }
}

struct ContentView: View {
    @ObservedObject var game: Game
    
    @State var showBorderWarning: Bool = false
    @State var uiBannerMessage: String = ""
    
    @State var selectedObject: (any BoardObject)?
    
    @State var printerCalibration: PrinterCalibration = PrinterCalibration(verticalOffset: 0.12, horizontalOffset: 0.23, rotation: Angle(degrees: -0.32))
    
    
    var body: some View {
        VStack {
            Text(uiBannerMessage)
                .font(.title)
            GeometryReader { geometry in
                HStack {
                    #warning("Dead Tanks List")
                    ZStack {
                        Color.white
                        SquareViewport(coordinates: Coordinates(x: 0, y: 0, rotation: .north), viewRenderSize: game.board.border + 1, highDetailSightRange: 1000000, lowDetailSightRange: 1000000, radarRange: 1000000, accessibilitySettings: AccessibilitySettings(), selectedObject: $selectedObject, game: game)
                            .frame(width: max(min(geometry.size.height, geometry.size.width), 300), height: max(min(geometry.size.height, geometry.size.width), 300), alignment: .center)
                    }
                    VStack {
                        TabView {
                            VStack {
                                Button("Enact Turn") {
                                    Task {
                                        await game.executeTurn()
                                        if game.isDeadDay {
                                            saveTurnToPDF(players: (game.board.objects.filter({ $0 is Player }) as! [Player]).filter({ !$0.playerInfo.doVirtualDelivery }), forGame: game, printerCalibration: printerCalibration)
                                        } else {
                                            saveTurnToPDF(players: (game.board.objects.filter({ $0 is Tank }) as! [Player]).filter({ !$0.playerInfo.doVirtualDelivery }), forGame: game, printerCalibration: printerCalibration)
                                        }
                                        for virtualPlayer in game.board.objects.filter({
                                            if ($0 is Player && game.isDeadDay) || ($0 is Tank) {
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
                                                createAndSavePDF(from: [AnyView(VirtualStatusCard(tank: virtualPlayer as! Tank, game: game))], fileName: "Virtual Status Card for \((virtualPlayer as! Player).playerInfo.fullName)", pageSize: CGSize(width: inch(12), height: inch(8)))
                                            } else {
#warning("Dead virtual Status Cards not implemented.")
                                            }
                                        }
                                        game.notes.removeAll()
                                        game.eventCardsToPrint.removeAll()
                                        game.actions.removeAll()
                                        game.messages.removeAll()
                                    }
                                }
                                
                                    Button("Print Turn Without Enacting") {
                                        if game.isDeadDay { #warning("Code repition.")
                                            saveTurnToPDF(players: (game.board.objects.filter({ $0 is Player }) as! [Player]).filter({ !$0.playerInfo.doVirtualDelivery }), forGame: game, printerCalibration: printerCalibration)
                                        } else {
                                            saveTurnToPDF(players: (game.board.objects.filter({ $0 is Tank }) as! [Player]).filter({ !$0.playerInfo.doVirtualDelivery }), forGame: game, printerCalibration: printerCalibration)
                                        }
                                        for virtualPlayer in game.board.objects.filter({
                                            if ($0 is Player && game.isDeadDay) || ($0 is Tank) {
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
                                                createAndSavePDF(from: [AnyView(VirtualStatusCard(tank: virtualPlayer as! Tank, game: game))], fileName: "Virtual Status Card for \((virtualPlayer as! Player).playerInfo.fullName)", pageSize: CGSize(width: inch(12), height: inch(8)))
                                            } else {
                                                
                                                    #warning("Dead virtual Status Cards not implemented.")
                                            }
                                        }
                                    }
                                Button("Print Full Board") {
                                    createAndSavePDF(from: [
                                        AnyView(
                                            SquareViewport(coordinates: Coordinates(x: 0, y: 0, rotation: .north), viewRenderSize: game.board.border + 1, highDetailSightRange: 1000000, lowDetailSightRange: 1000000, radarRange: 1000000, accessibilitySettings: AccessibilitySettings(), selectedObject: $selectedObject, game: game).frame(width: inch(8), height: inch(8))
                                        )
                                    ], fileName: "board")
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
                                    Stepper("Border", value: $game.board.border)
                                    Toggle("Show Border Warning", isOn: $game.board.showBorderWarning)
                                }
                                Spacer()
                                
                            }
                            .tabItem {
                                Label("Game", systemImage: "globe")
                            }
                            Inspector(object: $selectedObject, game: game)
                                .tabItem {
                                    Label("Inspector", systemImage: "info")
                                }
                            ActionList(game: game)
                                .tabItem {
                                    Label("Actions", systemImage: "righttriangle")
                                }
                            MessageList(game: game)
                                .tabItem {
                                    Label("Messages", systemImage: "message")
                                }
                            TurnNotesList(game: game)
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
