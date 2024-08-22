//
//  StatusCard.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 8/9/24.
//

import SwiftUI
import AppKit
import PDFKit

func inch(_ inches: CGFloat) -> CGFloat {
    return inches * 288
}

private func createAndSavePDF(from views: [AnyView]) {
    // Helper function to convert a SwiftUI view to NSImage
    func imageFromView(_ view: AnyView, size: CGSize) -> NSImage {
        let hostingController = NSHostingController(rootView: view)
        let rootView = hostingController.view
        
        rootView.frame = CGRect(origin: .zero, size: size)
        
        let offscreenView = NSView(frame: CGRect(origin: .zero, size: size))
        offscreenView.addSubview(rootView)
        
        let bitmapRep = NSBitmapImageRep(bitmapDataPlanes: nil,
                                         pixelsWide: Int(size.width),
                                         pixelsHigh: Int(size.height),
                                         bitsPerSample: 8,
                                         samplesPerPixel: 4,
                                         hasAlpha: true,
                                         isPlanar: false,
                                         colorSpaceName: .deviceRGB,
                                         bytesPerRow: 0,
                                         bitsPerPixel: 0)
        
        offscreenView.cacheDisplay(in: offscreenView.bounds, to: bitmapRep!)
        
        let image = NSImage(size: size)
        image.addRepresentation(bitmapRep!)
        
        return image
    }
    
    // Define page size for portrait orientation
    let pageSize = CGSize(width: inch(5.5), height: inch(8.5))
    
    // Create a PDF document
    let pdfDocument = PDFDocument()
    
    // Add each view as a separate page in the PDF document
    for view in views {
        let image = imageFromView(view, size: pageSize)
        let pdfPage = PDFPage(image: image)
        
        if let page = pdfPage {
            pdfDocument.insert(page, at: pdfDocument.pageCount)
        } else {
            print("Failed to create PDFPage from image.")
        }
    }
    
    // Create a temporary file URL to save the PDF
    let tempFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("output.pdf")
    
    // Save PDF to temporary file
    if let pdfData = pdfDocument.dataRepresentation() {
        do {
            try pdfData.write(to: tempFileURL)
            print("PDF saved to temporary file: \(tempFileURL.path)")
            
            // Open the PDF file using the system's default viewer
            NSWorkspace.shared.open(tempFileURL)
        } catch {
            print("Error saving PDF: \(error)")
        }
    } else {
        print("Failed to get PDF data representation.")
    }
}

struct StatusCardFront: View {
    let tank: Tank
    var body: some View {
        ZStack {
            VStack {
                VStack {
                    Spacer(minLength: inch(1.25))
                    Text(tank.formattedDailyMessage())
                        .font(.system(size: inch(0.15)))
                        .frame(width: inch(4.25), height: inch(4.25), alignment: .bottomLeading)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                        .fontDesign(.monospaced)
                }
                .rotationEffect(Angle(degrees: 90))
                .frame(width: inch(5.5), height: inch(4.25), alignment: .center)
                Spacer()
                Spacer(minLength: inch(4.25))
                
            }
            VStack {
                VStack {
                    Spacer()
                    Text(tank.playerDemographics.firstName)
                        .foregroundColor(.black)
                        .fontWeight(.ultraLight)
                        .font(.system(size: inch(0.35)))
                    Text(tank.playerDemographics.lastName)
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                        .font(.system(size: inch(0.35)))
                }
                .rotationEffect(Angle(degrees: -90))
                .frame(width: inch(4.875), height: inch(4.25), alignment: .center)
                VStack {
                    Text(tank.playerDemographics.deliveryBuilding)
                        .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                        .fontWeight(.light)
                        .font(.system(size: inch(0.35)))
                    HStack {
                        Text(tank.playerDemographics.deliveryType)
                            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                            .fontWeight(.medium)
                            .font(.system(size: inch(0.35)))
                        Text("\(tank.playerDemographics.deliveryNumber)")
                            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                            .fontWeight(.black)
                            .font(.system(size: inch(0.35)))
                    }
                    Spacer()
                }
                .rotationEffect(Angle(degrees: -90))
                .frame(width: inch(4.875), height: inch(4.25), alignment: .center)
            }
            VStack {
                HStack {
                    Image("")
                        .frame(width: inch(4.875), height: inch(4.25), alignment: .center)
                    MeterView(value: tank.fuel, max: 30, color: .green)
                        .frame(width: inch(0.625), height: inch(4.25), alignment: .center)
                    Spacer()
                }
                .frame(width: inch(5.5), height: inch(4.25), alignment: .top)
                HStack {
                    Spacer()
                    MeterView(value: tank.health, max: 100, color: .red)
                        .frame(width: inch(0.625), height: inch(4.25), alignment: .center)
                    Image("")
                        .frame(width: inch(4.875), height: inch(4.25), alignment: .center)
                }
                .frame(width: inch(5.5), height: inch(4.25), alignment: .bottom)
            }
        }
    }
}

struct StatusCardBack: View {
    let tank: Tank
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    HStack {
                        Spacer()
                        MeterView(value: tank.fuel, max: 30, color: .green)
                        Spacer()
                        MeterView(value: tank.metal, max: 30, color: .yellow)
                    }
                    .frame(width: inch(1.25), height: inch(4.25), alignment: .center)
                    Viewport(coordinates: tank.coordinates, cellSize: inch(3.95 / CGFloat(tank.radarRange * 2 + 1)), viewRenderSize: tank.radarRange, highDetailSightRange: tank.highDetailSightRange, lowDetailSightRange: tank.lowDetailSightRange, radarRange: tank.radarRange)
                        .frame(width: inch(4.25), height: inch(4.25), alignment: .center)
                }
                .frame(width: inch(5.5), height: inch(4.25), alignment: .top)
                HStack {
                    Text("This View is a placeholder for Tank drawings")
                        .frame(width: inch(4.25), height: inch(4.25), alignment: .center)
                        .font(.system(size: inch(0.5), weight: .bold, design: .default))
                        .foregroundColor(.black)
                    HStack {
                        MeterView(value: tank.metal, max: 30, color: .blue)
                        Spacer()
                        MeterView(value: tank.health, max: 100, color: .red)
                        Spacer()
                    }
                    .frame(width: inch(1.25), height: inch(4.25), alignment: .center)
                }
                .frame(width: inch(5.5), height: inch(4.25), alignment: .bottom)
            }
        }
    }
}

struct MeterView: View {
    let value: Int
    let max: Int
    let color: Color
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(color)
                .cornerRadius(inch(0.1))
                .frame(width: inch(0.5), height: inch((CGFloat(value) / CGFloat(max) * 4.25)), alignment: .bottom)
            Text("\(value)")
                .font(.system(size: inch(0.27)))
                .foregroundColor(.white)
                .bold()
        }
        .frame(width: inch(0.5), height: inch(4.25), alignment: .bottom)
    }
}

struct Viewport: View {
    let coordinates: Coordinates
    let cellSize: CGFloat
    let viewRenderSize: Int
    let highDetailSightRange: Int
    let lowDetailSightRange: Int
    let radarRange: Int
    var rerenderView: Bool = false
    
    func getAppearenceAtLocation(_ localCoordinates: Coordinates) -> Appearance {
        for tile in board.objects {
            if tile.coordinates.distanceTo(coordinates) <= radarRange {
                if tile.coordinates.distanceTo(coordinates) <= lowDetailSightRange {
                    if tile.coordinates.distanceTo(coordinates) <= highDetailSightRange {
                        if tile.coordinates == localCoordinates {
                            return tile.appearance
                        }
                    } else {
                        if (tile.coordinates == localCoordinates) && !(tile.appearance.fillColor == .white) {
                            return Appearance(fillColor: tile.appearance.fillColor, strokeColor: tile.appearance.fillColor, symbolColor: tile.appearance.fillColor, symbol: "rectangle")
                        }
                    }
                } else {
                    if (tile.coordinates == localCoordinates) && !(tile.appearance.fillColor == .white) {
                        let mysteryObject = Color(red: 0.4, green: 0.4, blue: 0.4)
                        return Appearance(fillColor: mysteryObject, strokeColor: mysteryObject, symbolColor: mysteryObject, symbol: "rectangle")
                    }
                }
            }
        }
        if coordinates.distanceTo(localCoordinates) <= radarRange {
            if coordinates.distanceTo(localCoordinates) <= lowDetailSightRange {
                if coordinates.distanceTo(localCoordinates) <= highDetailSightRange {
                    return Appearance(fillColor: .white, strokeColor: .white, symbolColor: .white, symbol: "rectangle")
                }
                let fog = Color(red: 0.9, green: 0.9, blue: 0.9)
                return Appearance(fillColor: fog, strokeColor: fog, symbolColor: fog, symbol: "rectangle")
            }
            let fog = Color(red: 0.8, green: 0.8, blue: 0.8)
            return Appearance(fillColor: fog, strokeColor: fog, symbolColor: fog, symbol: "rectangle")
        }
        let fog = Color(red: 0.7, green: 0.7, blue: 0.7)
        return Appearance(fillColor: fog, strokeColor: fog, symbolColor: fog, symbol: "rectangle")
    }

    var body: some View {
        HStack {
            ForEach(coordinates.x - viewRenderSize...coordinates.x + viewRenderSize, id: \.self) { x in
                VStack {
                    ForEach((-coordinates.y - viewRenderSize)...(-coordinates.y + viewRenderSize), id: \.self) { y in
                        var thisTile = board.objects.first(
                            where: { $0.coordinates == Coordinates(x: x, y: -y) }) ?? nil
                        ZStack {
                            let thisTileAppearance = getAppearenceAtLocation(Coordinates(x: x, y: -y))
                            Rectangle()
                            .foregroundColor(thisTileAppearance.fillColor)
                                .frame(width: cellSize, height: cellSize)
                            .border(thisTileAppearance.strokeColor, width: cellSize / 10)
                                .cornerRadius(cellSize / 10)
                            Image(systemName: thisTileAppearance.symbol)
                            .foregroundColor(thisTileAppearance.symbolColor)
                                .frame(width: cellSize, height: cellSize)
                                .font(.system(size: cellSize / 2))
                        }
                        .frame(width: cellSize, height: cellSize)
                        .padding(.all, -3)
                        .contextMenu {
                            if thisTile != nil {
                                Menu("Attributes") {
                                    if thisTile is Tank {
                                        Section("   Player Demographics") {
                                            Text("Name: \((thisTile! as! Tank).playerDemographics.firstName) \((thisTile! as! Tank).playerDemographics.lastName)")
                                            Text("Delivery Location: \((thisTile! as! Tank).playerDemographics.deliveryType) \((thisTile! as! Tank).playerDemographics.deliveryNumber) in \((thisTile! as! Tank).playerDemographics.deliveryBuilding)")
                                        }
                                        Section("   Tank Attributes") {
                                            Text("Fuel: \((thisTile! as! Tank).fuel)")
                                            Text("Metal: \((thisTile! as! Tank).metal)")
                                            Menu("Daily Message") {
                                                Text((thisTile! as! Tank).dailyMessage)
                                        }
                                        Menu("Upgrades") {
                                            Section("   Movement") {
                                                Text("Speed: \((thisTile! as! Tank).movementSpeed) Tiles/Turn")
                                                Text("Cost: \((thisTile! as! Tank).movementCost) Fuel")
                                            }
                                            Section("   Weaponry") {
                                                Text("Range: \((thisTile! as! Tank).gunRange) Tiles")
                                                Text("Damage: \((thisTile! as! Tank).gunDamage) Health")
                                                Text("Cost: \((thisTile! as! Tank).gunCost) Fuel")
                                            }
                                            Section("   Sight Range") {
                                                Text("High Detail: \((thisTile! as! Tank).highDetailSightRange) Tiles")
                                                Text("Low Detail: \((thisTile! as! Tank).lowDetailSightRange) Tiles")
                                                Text("Radar: \((thisTile! as! Tank).radarRange) Tiles")
                                            }
                                        }
                                    }
                                }
                                Section("   General Attributes") {
                                    Text("XY: \(thisTile!.coordinates.x), \(thisTile!.coordinates.y)")
                                    Text("Health: \(thisTile!.health)")
                                    Text("Defence: \(thisTile!.defence)")
                                    Text("Fuel Dropped: \(thisTile!.fuelDropped)")
                                    Text("Metal Dropped: \(thisTile!.metalDropped)")
                                }
                            }
                                Button("Delete") {
                                    board.objects.removeAll(where: {
                                    $0 == thisTile})
                                }
                                if thisTile is Tank {
                                    Button("Print Status...") {
                                        saveStatusCardsToPDF([thisTile! as! Tank])
                                    }
                                }
                            } else {
                            Button("Add Wall") {
                                board.objects.append(Wall(coordinates: Coordinates(x: x, y: -y)))
                            }
                            Button("Add Gift") {
                                let totalReward: Int = 20
                                let metalReward: Int = Int.random(in: 0...totalReward)
                                let fuelReward: Int = totalReward - metalReward
                                board.objects.append(Gift(coordinates: Coordinates(x: x, y: -y), fuelReward: fuelReward, metalReward: metalReward))
                            }
                            }
                        }
                        .onTapGesture {
                            
                        }
                    }
                }
            }
        }
    }
}



func saveStatusCardsToPDF(_ tanks: [Tank]) {
    var pages: [AnyView] = []
    for tank in tanks {
        pages.append(AnyView(StatusCardFront(tank: tank)))
        pages.append(AnyView(StatusCardBack(tank: tank)))
    }
    createAndSavePDF(from: pages)
}

let lipsum = """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent ligula quam, semper quis fringilla nec, elementum eget magna. Donec finibus auctor efficitur. Sed vulputate est sed augue mollis malesuada. Vestibulum dictum molestie congue. Praesent justo lorem, convallis quis ex porttitor, porta posuere turpis. Aliquam a tristique est. Praesent ut felis et mi suscipit porttitor. Aenean justo risus, luctus dignissim fringilla ac, congue consequat velit. In hac habitasse platea dictumst. Maecenas a nisi a sapien gravida vulputate sit amet vel mauris. Nullam lectus massa, hendrerit at viverra auctor, aliquam eget augue. Sed nec arcu ipsum. Quisque pulvinar semper augue id ornare. Curabitur finibus nisi at semper scelerisque. Mauris dictum laoreet ullamcorper.
"""

let previewTank = Tank(
    appearance: Appearance(fillColor: .red, strokeColor: .orange, symbolColor: .orange, symbol: "printer.fill"), coordinates: Coordinates(x: 0, y: 0), playerDemographics: PlayerDemographics(firstName: "Rodriguezz", lastName: "Appleseed-Bonjoir", deliveryBuilding: "Apple Park, Cuperino, CA", deliveryType: "Window", deliveryNumber: 101), dailyMessage: lipsum)
#Preview("Front") {
    StatusCardFront(tank: previewTank)
}
#Preview("Back") {
    StatusCardBack(tank: previewTank)
}
