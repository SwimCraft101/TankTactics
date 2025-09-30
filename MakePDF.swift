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

func saveTurnToPDF(players: [Player], messages messagesIn: [Message], eventCards eventCardsIn: [EventCard], notes notesIn: [String], doAlignmentCompensation: Bool) {
    var pages: [AnyView] = []
    var playersToPrintInConduitMode: [Player] = players.filter({ $0.statusCardConduitBack() != nil })
    playersToPrintInConduitMode.removeAll(where: { $0.playerInfo.accessibilitySettings.largeText })
    var playersToPrintNormally: [Player] = players.filter({ $0.statusCardConduitBack() == nil })
    playersToPrintNormally.removeAll(where: { $0.playerInfo.accessibilitySettings.largeText })
    var playersToPrintWithLargeText: [Player] = players.filter({ $0.playerInfo.accessibilitySettings.largeText })
    var messages = messagesIn
    var eventCards = eventCardsIn
    var notes = notesIn
    
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
            .padding(.trailing, inch(doAlignmentCompensation ? 0.25 : 0))
            .padding(.bottom, inch(doAlignmentCompensation ? 0.1 : 0))
            .rotationEffect(Angle(degrees: doAlignmentCompensation ? -0.3 : 0))
            .frame(width: inch(11), height: inch(8.5), alignment: .center)
            .environment(Game.shared)
        ))
        
        if player.statusCardConduitBack() != nil {
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
                .padding(.trailing, inch(doAlignmentCompensation ? 0.25 : 0))
                .padding(.bottom, inch(doAlignmentCompensation ? 0.1 : 0))
                .rotationEffect(Angle(degrees: doAlignmentCompensation ? -0.3 : 0))
                .frame(width: inch(11), height: inch(8.5))
                .environment(Game.shared)
            ))
        }
    }
    
    while playersToPrintInConduitMode.count > 0 {
        let player = playersToPrintInConduitMode.removeFirst()
        pages.append(AnyView(HStack(spacing:0) {
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
                if !messages.isEmpty {
                    MessageView(message: messages.first!)
                        .frame(width: inch(3.1819805153), height: inch(2.4748737342), alignment: .bottomTrailing)
                        .frame(width: inch(5), height: inch(4), alignment: .bottomTrailing)
                } else if !eventCards.isEmpty {
                    eventCards.removeFirst()
                        .frame(width: inch(5), height: inch(4))
                } else {
                    VStack {
                        ForEach(notes, id: \.self) { note in
                            Text(note)
                                .font(.system(size: inch(0.1)))
                        }
                    }
                }
            }
            .frame(width: inch(5), height: inch(8), alignment: .top)
        }
            .border(.black, width: inch(0.005))
            .frame(width: inch(10), height: inch(8))
            .frame(width: inch(11), height: inch(8.5), alignment: .center)
            .environment(Game.shared)))
        pages.append(AnyView(HStack(spacing:0) {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: inch(0.005))
                        .frame(width: inch(1), height: inch(4), alignment: .trailing)
                    player.statusCardConduitBack()!
                        .frame(width: inch(4), height: inch(4), alignment: .trailing)
                }
                Rectangle()
                    .fill(Color.black)
                    .frame(height: inch(0.005))
                if !messages.isEmpty {
                    MessageBackView(message: messages.removeFirst())
                        .frame(width: inch(3.1819805153), height: inch(2.4748737342), alignment: .bottomLeading)
                        .frame(width: inch(5), height: inch(4), alignment: .bottomLeading)
                }
            }
            .frame(width: inch(5), height: inch(8), alignment: .top)
            player.statusCardBack()
                .frame(width: inch(5), height: inch(8))
        }
            .border(.black, width: inch(0.005))
            .frame(width: inch(10), height: inch(8))
            .padding(.trailing, inch(doAlignmentCompensation ? 0.25 : 0))
            .padding(.bottom, inch(doAlignmentCompensation ? 0.1 : 0))
            .rotationEffect(Angle(degrees: doAlignmentCompensation ? -0.3 : 0))
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
            .padding(.trailing, inch(doAlignmentCompensation ? 0.25 : 0))
            .padding(.bottom, inch(doAlignmentCompensation ? 0.1 : 0))
            .rotationEffect(Angle(degrees: doAlignmentCompensation ? -0.3 : 0))
            .frame(width: inch(11), height: inch(8.5), alignment: .center)
            .environment(Game.shared)
        ))
    }
    
    if playersToPrintNormally.count > 0 {
        let player = playersToPrintNormally.removeFirst()
        pages.append(AnyView(HStack(spacing: 0) {
            player.statusCardFront()
                .frame(width: inch(5), height: inch(8))
            EmptyView()
                .frame(width: inch(5), height: inch(8))
        }
            .frame(width: inch(10), height: inch(8))
            .border(.black, width: inch(0.005))
            .frame(width: inch(11), height: inch(8.5), alignment: .center)
            .environment(Game.shared)))
        pages.append(AnyView(HStack(spacing: 0) {
            EmptyView()
            player.statusCardBack()
                .frame(width: inch(5), height: inch(8))
        }
            .frame(width: inch(10), height: inch(8))
            .border(.black, width: inch(0.005))
            .padding(.trailing, inch(doAlignmentCompensation ? 0.25 : 0))
            .padding(.bottom, inch(doAlignmentCompensation ? 0.1 : 0))
            .rotationEffect(Angle(degrees: doAlignmentCompensation ? -0.3 : 0))
            .frame(width: inch(11), height: inch(8.5), alignment: .center)
            .environment(Game.shared)
        ))
    }
    
    while !messages.isEmpty {
        pages.append(AnyView(HStack(spacing: 0) {
            Grid(alignment: .topLeading, horizontalSpacing: 0, verticalSpacing: 0) {
                GridRow {
                    MessageView(message: messages[safe: 0])
                        .frame(width: inch(3.535534), height: inch(2.715679), alignment: .topLeading)
                    MessageView(message: messages[safe: 1])
                        .frame(width: inch(3.535534), height: inch(2.715679), alignment: .topLeading)
                }
                GridRow {
                    MessageView(message: messages[safe: 2])
                        .frame(width: inch(3.535534), height: inch(2.715679), alignment: .topLeading)
                    MessageView(message: messages[safe: 3])
                        .frame(width: inch(3.535534), height: inch(2.715679), alignment: .topLeading)
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
                    MessageBackView(message: messages[safe: 1])
                        .frame(width: inch(3.535534), height: inch(2.715679), alignment: .topTrailing)
                    MessageBackView(message: messages[safe: 0])
                        .frame(width: inch(3.535534), height: inch(2.715679), alignment: .topTrailing)
                }
                GridRow {
                    MessageBackView(message: messages[safe: 3])
                        .frame(width: inch(3.535534), height: inch(2.715679), alignment: .topTrailing)
                    MessageBackView(message: messages[safe: 2])
                        .frame(width: inch(3.535534), height: inch(2.715679), alignment: .topTrailing)
                }
            }
        }
            .frame(width: inch(10), height: inch(8))
            .border(.black, width: inch(0.005))
            .padding(.trailing, inch(doAlignmentCompensation ? 0.25 : 0))
            .padding(.bottom, inch(doAlignmentCompensation ? 0.1 : 0))
            .rotationEffect(Angle(degrees: doAlignmentCompensation ? -0.3 : 0))
            .frame(width: inch(11), height: inch(8.5), alignment: .center)
            .environment(Game.shared)
        ))
        if messages.count <= 4 {
            messages.removeAll()
        } else {
            messages.removeFirst(4)
        }
    }
    
    while !eventCards.isEmpty {
        pages.append(AnyView(HStack(spacing: 0) {
            Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                GridRow {
                    eventCards[safe: 0]
                    eventCards[safe: 1]
                }
                GridRow {
                    eventCards[safe: 2]
                    eventCards[safe: 3]
                }
            }
        }
            .frame(width: inch(10), height: inch(8))
            .border(.black, width: inch(0.005))
            .frame(width: inch(11), height: inch(8.5), alignment: .center)
            .environment(Game.shared)))
        pages.append(AnyView(EmptyView()))
        if eventCards.count <= 4 {
            eventCards.removeAll()
        } else {
            eventCards.removeFirst(4)
        }
    }
    
    createAndSavePDF(from: pages, fileName: "Turn")
}
