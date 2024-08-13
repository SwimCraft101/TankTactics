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
    return inches * 72
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
            Image("Status Card Front")
                .scaledToFill()
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
            Image("Status Card Back")
                .scaledToFill()
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
                    Text("This View is a placeholder for later (:")
                        .frame(width: inch(4.25), height: inch(4.25), alignment: .center)
                        .font(.system(size: inch(0.5), weight: .bold, design: .default))
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
                .font(.system(size: 20))
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
                        ZStack {
                            let thisTileAppearance = getAppearenceAtLocation(Coordinates(x: x, y: -y))
                            Rectangle()
                                .foregroundColor(thisTileAppearance.fillColor)
                                .frame(width: cellSize, height: cellSize)
                                .border(thisTileAppearance.strokeColor, width: cellSize / 10)
                                .cornerRadius(cellSize / 20)
                            Image(systemName: thisTileAppearance.symbol)
                                .foregroundColor(thisTileAppearance.symbolColor)
                                .frame(width: cellSize, height: cellSize)
                                .aspectRatio(contentMode: .fill)
                        }
                        .frame(width: cellSize, height: cellSize)
                        .padding(.all, -3)
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

#Preview("Front") {
    var exampleTank = Tank(appearance: Appearance(fillColor: .red, strokeColor: .orange, symbolColor: .orange, symbol: "printer.fill"), coordinates: Coordinates(x: 0, y: 0), playerDemographics: PlayerDemographics(firstName: "John", lastName: "Appleseed", deliveryBuilding: "Apple Park", deliveryType: "Window", deliveryNumber: 101))
    StatusCardFront(tank: exampleTank)
}

#Preview("Back") {
    var exampleTank = Tank(appearance: Appearance(fillColor: .red, strokeColor: .orange, symbolColor: .orange, symbol: "printer.fill"), coordinates: Coordinates(x: 0, y: 0), playerDemographics: PlayerDemographics(firstName: "John", lastName: "Appleseed", deliveryBuilding: "Apple Park", deliveryType: "Window", deliveryNumber: 101))
    StatusCardBack(tank: exampleTank)
}
