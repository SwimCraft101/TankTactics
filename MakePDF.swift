//
//  MakePDF.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 10/3/24.
//
import SwiftUI
import AppKit
import PDFKit

func imageFromView(_ view: AnyView, size: CGSize) -> NSImage {
    let hostingController = NSHostingController(rootView: view)
    let rootView = hostingController.view
    
    rootView.frame = CGRect(origin: .zero, size: size)
    
    let offscreenView = NSView(frame: CGRect(origin: .zero, size: size))
    offscreenView.addSubview(rootView)
    
    let bitmapRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(size.width), pixelsHigh: Int(size.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)
    
    offscreenView.cacheDisplay(in: offscreenView.bounds, to: bitmapRep!)
    
    let image = NSImage(size: size)
    image.addRepresentation(bitmapRep!)
    
    return image
}

struct PrinterCalibration {
    var verticalOffset: CGFloat //A value to offset in Inches
    var horizontalOffset: CGFloat //A value to offset in Inches
    var rotation: Angle
    
    static func defaultValue() -> Self {
        return Self(verticalOffset: 0, horizontalOffset: 0, rotation: .zero)
    }
}

extension View {
    nonisolated func compensateForPrinterAlignment(_ printerCalibration: PrinterCalibration) -> some View {
        return self
            .padding(.trailing, inch(printerCalibration.horizontalOffset))
            .padding(.bottom, inch(printerCalibration.verticalOffset))
            .rotationEffect(printerCalibration.rotation)
    }
}

func createAndSavePDF(from views: [AnyView], fileName: String, pageSize: CGSize = CGSize(width: inch(11), height: inch(8.5))) {
    // Define page size for portrait orientation
    let pageSize = CGSize(width: inch(11), height: inch(8.5))
    
    // Create a PDF document
    let pdfDocument = PDFDocument()
    
    // Add each view as a separate page in the PDF document
    for view in views {
        let image = imageFromView(AnyView(view.environment(Game.shared)), size: pageSize)
        let pdfPage = PDFPage(image: image)
        
        if let page = pdfPage {
            pdfDocument.insert(page, at: pdfDocument.pageCount)
        } else {
            print("Failed to create PDFPage from image.")
        }
    }
    
    // Create a temporary file URL to save the PDF
    let tempFileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
    
    // Save PDF to temporary file
    if let pdfData = pdfDocument.dataRepresentation() {
        do {
            try pdfData.write(to: tempFileURL)
            
            // Open the PDF file using the system's default viewer
            NSWorkspace.shared.open(tempFileURL)
        } catch {}
    }
}

func saveTurnToPDF(players: [Player], messages messagesIn: [Message], eventCards eventCardsIn: [EventCard], notes notesIn: [String], printerCalibration: PrinterCalibration) {
    var pages: [AnyView] = []
    var playersToPrintInConduitMode: [Player] = players.filter({ $0.statusCardConduitFront() != nil })
    playersToPrintInConduitMode.removeAll(where: { $0.playerInfo.accessibilitySettings.largeText })
    var playersToPrintNormally: [Player] = players.filter({ $0.statusCardConduitFront() == nil })
    playersToPrintNormally.removeAll(where: { $0.playerInfo.accessibilitySettings.largeText })
    var playersToPrintWithLargeText: [Player] = players.filter({ $0.playerInfo.accessibilitySettings.largeText })
    var messages = messagesIn
    var eventCards = eventCardsIn
    var notes = notesIn
    
    var extraCards: [(AnyView, AnyView)] = []
    
    while !messages.isEmpty {
        extraCards.append(
            (
                AnyView(MessageView(message: messages.first)),
                AnyView(MessageBackView(message: messages.removeFirst()))
            )
        )
    }
    
    while !eventCards.isEmpty {
        extraCards.append(
            (
                AnyView(eventCards.removeFirst()),
                AnyView(Rectangle().fill(.white).frame(width: inch(3.535534), height: inch(2.715679)))
            )
        )
    }
    
    while !notes.isEmpty {
        extraCards.append(
            (
                AnyView(Text(notes.removeFirst()).font(.system(size: inch(0.15))).frame(width: inch(3.535534), height: inch(2.715679))),
                AnyView(Rectangle().fill(.white).frame(width: inch(3.535534), height: inch(2.715679)))
            )
        )
    }
    
    while playersToPrintWithLargeText.count > 0 {
        let player = playersToPrintWithLargeText.removeFirst()
        pages.append(AnyView(HStack(spacing:0) {
            player.statusCardFront()
                .scaleEffect(21/16)
                .rotationEffect(Angle(degrees: 90))
        }
            .frame(width: inch(10.5), height: inch(105/16))
            .border(.black, width: inch(0.005))
            .frame(width: inch(11), height: inch(8.5), alignment: .center)
            .environment(Game.shared)))
        pages.append(AnyView(HStack(spacing:0) {
            player.statusCardBack()
                .scaleEffect(21/16)
                .rotationEffect(Angle(degrees: -90))
        }
            .frame(width: inch(10.5), height: inch(105/16))
            .border(.black, width: inch(0.005))
            .compensateForPrinterAlignment(printerCalibration)
            .frame(width: inch(11), height: inch(8.5), alignment: .center)
            .environment(Game.shared)
        ))
        
        if player.statusCardConduitFront() != nil {
            pages.append(AnyView(HStack(spacing:0) {
                player.statusCardConduitFront()
                    .scaleEffect(21/16)
            }
                .frame(width: inch(21/4), height: inch(21/4))
                .border(.black, width: inch(0.005))
                .frame(width: inch(11), height: inch(8.5))
                .environment(Game.shared)))
            pages.append(AnyView(HStack(spacing:0) {
                player.statusCardConduitBack()
                    .scaleEffect(21/16)
            }
                .frame(width: inch(21/4), height: inch(21/4))
                .border(.black, width: inch(0.005))
                .compensateForPrinterAlignment(printerCalibration)
                .frame(width: inch(11), height: inch(8.5))
                .environment(Game.shared)
            ))
        }
    }
    
    while playersToPrintInConduitMode.count > 0 {
        let player = playersToPrintInConduitMode.removeFirst()
        pages.append(
            AnyView(
                HStack(spacing:0) {
                    player.statusCardFront()
                        .frame(width: inch(5), height: inch(8))
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            player.statusCardConduitFront()!
                                .frame(width: inch(4), height: inch(4), alignment: .leading)
                            Rectangle()
                                .fill(Color.black)
                                .frame(width: inch(0.005))
                                .frame(width: inch(1), height: inch(4), alignment: .leading)
                        }
                        Rectangle()
                            .fill(Color.black)
                            .frame(height: inch(0.005))
                        if !extraCards.isEmpty {
                            extraCards.first!.0
                                .frame(width: inch(3.535534), height: inch(2.715679), alignment: .bottomTrailing)
                                .frame(width: inch(5), height: inch(4), alignment: .bottomTrailing)
                        }
                    }
                    .frame(width: inch(5), height: inch(8), alignment: .top)
                }
            .border(.black, width: inch(0.005))
            .frame(width: inch(10), height: inch(8))
            .frame(width: inch(11), height: inch(8.5), alignment: .center)
            .environment(Game.shared)
            )
        )
        pages.append(AnyView(HStack(spacing:0) {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: inch(0.005))
                        .frame(width: inch(1), height: inch(4), alignment: .trailing)
                    AnyView(player.statusCardConduitBack() ?? AnyView(Rectangle().foregroundStyle(.white)))
                        .frame(width: inch(4), height: inch(4), alignment: .trailing)
                }
                Rectangle()
                    .fill(Color.black)
                    .frame(height: inch(0.005))
                if !extraCards.isEmpty {
                    extraCards.removeFirst().1
                        .frame(width: inch(3.535534), height: inch(2.715679), alignment: .bottomLeading)
                        .frame(width: inch(5), height: inch(4), alignment: .bottomLeading)
                }
            }
            .frame(width: inch(5), height: inch(8), alignment: .top)
            player.statusCardBack()
                .frame(width: inch(5), height: inch(8))
        }
            .border(.black, width: inch(0.005))
            .frame(width: inch(10), height: inch(8))
            .compensateForPrinterAlignment(printerCalibration)
            .frame(width: inch(11), height: inch(8.5), alignment: .center)
            .environment(Game.shared)
        ))
    }
    
    while playersToPrintNormally.count > 1 {
        let player1 = playersToPrintNormally.removeFirst()
        let player2 = playersToPrintNormally.removeFirst()
        
        pages.append(AnyView(HStack(spacing: 0) {
            player1.statusCardFront()
                .frame(width: inch(5), height: inch(8))
            player2.statusCardFront()
                .frame(width: inch(5), height: inch(8))
        }
            .frame(width: inch(10), height: inch(8))
            .border(.black, width: inch(0.005))
            .frame(width: inch(11), height: inch(8.5), alignment: .center)
            .environment(Game.shared)))
        pages.append(AnyView(HStack(spacing: 0) {
            player2.statusCardBack()
                .frame(width: inch(5), height: inch(8))
            player1.statusCardBack()
                .frame(width: inch(5), height: inch(8))
        }
            .frame(width: inch(10), height: inch(8))
            .border(.black, width: inch(0.005))
            .compensateForPrinterAlignment(printerCalibration)
            .frame(width: inch(11), height: inch(8.5), alignment: .center)
            .environment(Game.shared)
        ))
    }
    
    if playersToPrintNormally.count > 0 {
        let player = playersToPrintNormally.removeFirst()
        pages.append(AnyView(HStack(spacing: 0) {
            player.statusCardFront()
                .frame(width: inch(5), height: inch(8))
            VStack(spacing: 0) {
                extraCards[safe: 0]?.0 ?? AnyView(Rectangle().foregroundColor(.white).frame(width: inch(3.535534), height: inch(2.715679)))
                extraCards[safe: 1]?.0 ?? AnyView(Rectangle().foregroundColor(.white).frame(width: inch(3.535534), height: inch(2.715679)))
            }
                .frame(width: inch(5), height: inch(8))
        }
            .frame(width: inch(10), height: inch(8))
            .border(.black, width: inch(0.005))
            .frame(width: inch(11), height: inch(8.5), alignment: .center)
            .environment(Game.shared)))
        pages.append(AnyView(HStack(spacing: 0) {
            VStack(spacing: 0) {
                extraCards[safe: 0]?.1 ?? AnyView(Rectangle().foregroundColor(.white).frame(width: inch(3.535534), height: inch(2.715679)))
                extraCards[safe: 1]?.1 ?? AnyView(Rectangle().foregroundColor(.white).frame(width: inch(3.535534), height: inch(2.715679)))
            }
            .frame(width: inch(5), height: inch(8))
            player.statusCardBack()
                .frame(width: inch(5), height: inch(8))
        }
            .frame(width: inch(10), height: inch(8))
            .border(.black, width: inch(0.005))
            .compensateForPrinterAlignment(printerCalibration)
            .frame(width: inch(11), height: inch(8.5), alignment: .center)
            .environment(Game.shared)
        ))
        
        if extraCards.count <= 2 {
            extraCards.removeAll()
        } else {
            extraCards.removeFirst(2)
        }
    }
    
    while !extraCards.isEmpty {
        pages.append(AnyView(HStack(spacing: 0) {
            Grid(alignment: .topLeading, horizontalSpacing: 0, verticalSpacing: 0) {
                GridRow {
                    AnyView(
                        (extraCards[safe: 0]?.0 ?? AnyView(Rectangle().foregroundColor(.white)))
                        .frame(width: inch(3.535534), height: inch(2.715679), alignment: .topLeading)
                        )
                    AnyView(
                        (extraCards[safe: 1]?.0 ?? AnyView(Rectangle().foregroundColor(.white)))
                        .frame(width: inch(3.535534), height: inch(2.715679), alignment: .topLeading)
                        )
                }
                GridRow {
                    AnyView(
                        (extraCards[safe: 2]?.0 ?? AnyView(Rectangle().foregroundColor(.white)))
                        .frame(width: inch(3.535534), height: inch(2.715679), alignment: .topLeading)
                        )
                    AnyView(
                        (extraCards[safe: 3]?.0 ?? AnyView(Rectangle().foregroundColor(.white)))
                        .frame(width: inch(3.535534), height: inch(2.715679), alignment: .topLeading)
                        )
                }
            }
        }
            .frame(width: inch(10), height: inch(8))
            .border(.black, width: inch(0.005))
            .frame(width: inch(11), height: inch(8.5), alignment: .center)
            .environment(Game.shared)))
        pages.append(AnyView(HStack(spacing: 0) {
            Grid(alignment: .topTrailing, horizontalSpacing: 0, verticalSpacing: 0) {
                GridRow {
                    AnyView(
                        (extraCards[safe: 1]?.1 ?? AnyView(Rectangle().foregroundColor(.white)))
                        .frame(width: inch(3.535534), height: inch(2.715679), alignment: .topTrailing)
                        )
                    AnyView(
                        (extraCards[safe: 0]?.1 ?? AnyView(Rectangle().foregroundColor(.white)))
                        .frame(width: inch(3.535534), height: inch(2.715679), alignment: .topTrailing)
                        )
                }
                GridRow {
                    AnyView(
                        (extraCards[safe: 3]?.1 ?? AnyView(Rectangle().foregroundColor(.white)))
                        .frame(width: inch(3.535534), height: inch(2.715679), alignment: .topTrailing)
                        )
                    AnyView(
                        (extraCards[safe: 2]?.1 ?? AnyView(Rectangle().foregroundColor(.white)))
                        .frame(width: inch(3.535534), height: inch(2.715679), alignment: .topTrailing)
                        )
                }
            }
        }
            .frame(width: inch(10), height: inch(8))
            .border(.black, width: inch(0.005))
            .compensateForPrinterAlignment(printerCalibration)
            .frame(width: inch(11), height: inch(8.5), alignment: .center)
            .environment(Game.shared)
        ))
        if extraCards.count <= 4 {
            extraCards.removeAll()
        } else {
            extraCards.removeFirst(4)
        }
    }
    
    createAndSavePDF(from: pages, fileName: "Turn")
}
