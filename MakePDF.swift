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

func createAndSavePDF(from views: [AnyView], fileName: String) {
    // Define page size for portrait orientation
    let pageSize = CGSize(width: inch(11), height: inch(8.5))
    
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

func saveTurnToPDF(players: [Player], messages messagesIn: [Message], doAlignmentCompensation: Bool) {
    var pages: [AnyView] = []
    var playersToPrintInConduitMode: [Player] = players.filter { $0.statusCardConduitBack() != nil }
    var playersToPrintNormally: [Player] = players.filter { $0.statusCardConduitBack() == nil }
    var messages = messagesIn
    
    while playersToPrintInConduitMode.count > 0 {
        let player = playersToPrintInConduitMode.removeFirst()
        pages.append(AnyView(HStack(spacing:0) {
            player.statusCardFront()
                .frame(width: inch(5), height: inch(8))
            VStack(spacing: 0) {
                player.statusCardConduitFront()!
                    .frame(width: inch(5), height: inch(4), alignment: .leading)
                if !messages.isEmpty {
                    MessageView(message: messages.first!)
                        .frame(width: inch(5), height: inch(4), alignment: .center)
                } else { //MARK: only print one Turn Report
                    //TurnReport()//MARK: implement Turn Reports
                    //.frame(width: inch(5), height: inch(4), alignment: .center)
                }
            }
        }.frame(width: inch(10), height: inch(8)).border(.black, width: inch(0.05)).frame(width: inch(11), height: inch(8.5), alignment: .center)))
        pages.append(AnyView(HStack(spacing:0) {
            VStack(spacing: 0) {
                player.statusCardConduitBack()!
                    .frame(width: inch(5), height: inch(4), alignment: .leading)
                if !messages.isEmpty {
                    MessageBackView(message: messages.removeFirst())
                        .frame(width: inch(5), height: inch(4), alignment: .center)
                }
            }
            player.statusCardBack()
                .frame(width: inch(5), height: inch(8))
        }
            .frame(width: inch(10), height: inch(8))
            .border(.black, width: inch(0.05))
            .padding(.trailing, inch(doAlignmentCompensation ? 0.25 : 0))
            .padding(.bottom, inch(doAlignmentCompensation ? 0.1 : 0))
            .rotationEffect(Angle(degrees: doAlignmentCompensation ? -0.3 : 0))
            .frame(width: inch(11), height: inch(8.5), alignment: .center)
        ))
    }
    
    while playersToPrintNormally.count > 1 {
        let player1 = playersToPrintNormally.removeFirst()
        let player2 = playersToPrintNormally.removeFirst()
        
        pages.append(AnyView(HStack(spacing:0) {
            player1.statusCardFront()
                .frame(width: inch(5), height: inch(8))
            player2.statusCardFront()
                .frame(width: inch(5), height: inch(8))
        }.frame(width: inch(10), height: inch(8)).border(.black, width: inch(0.05)).frame(width: inch(11), height: inch(8.5), alignment: .center)))
        pages.append(AnyView(HStack(spacing:0) {
            player2.statusCardBack()
                .frame(width: inch(5), height: inch(8))
            player1.statusCardBack()
                .frame(width: inch(5), height: inch(8))
        }
            .frame(width: inch(10), height: inch(8))
            .border(.black, width: inch(0.05))
            .padding(.trailing, inch(doAlignmentCompensation ? 0.25 : 0))
            .padding(.bottom, inch(doAlignmentCompensation ? 0.1 : 0))
            .rotationEffect(Angle(degrees: doAlignmentCompensation ? -0.3 : 0))
            .frame(width: inch(11), height: inch(8.5), alignment: .center)
        ))
    }
    
    if playersToPrintNormally.count > 0 {
        let player = playersToPrintNormally.removeFirst()
        pages.append(AnyView(HStack(spacing:0) {
            player.statusCardFront()
                .frame(width: inch(5), height: inch(8))
            EmptyView()
                .frame(width: inch(5), height: inch(8))
        }.frame(width: inch(10), height: inch(8)).border(.black, width: inch(0.05)).frame(width: inch(11), height: inch(8.5), alignment: .center)))
        pages.append(AnyView(HStack(spacing:0) {
            EmptyView()
            player.statusCardBack()
                .frame(width: inch(5), height: inch(8))
        }
            .frame(width: inch(10), height: inch(8))
            .border(.black, width: inch(0.05))
            .padding(.trailing, inch(doAlignmentCompensation ? 0.25 : 0))
            .padding(.bottom, inch(doAlignmentCompensation ? 0.1 : 0))
            .rotationEffect(Angle(degrees: doAlignmentCompensation ? -0.3 : 0))
            .frame(width: inch(11), height: inch(8.5), alignment: .center)
        ))
    }
}

func saveDeadStatusCardsToPDF(_ tanks: [DeadTank], doAlignmentCompensation: Bool) { //MARK: merge with living player function. allow Conduit fold-out flaps to be added as such. fetch status card info with the method of Tank and not directly.
    var workingTanks = tanks.filter({ !($0.doVirtualDelivery) })
    var pages: [AnyView] = []
    var tanksTwoByTwo: [[DeadTank?]] = []
    while workingTanks.count > 0 {
        if workingTanks.count > 1 {
            tanksTwoByTwo.append([workingTanks.removeFirst(), workingTanks.removeFirst()])
        } else if workingTanks.count == 1 {
            tanksTwoByTwo.append([workingTanks.removeFirst(), nil])
        }
    }
    for tankPair in tanksTwoByTwo {
        pages.append(AnyView(HStack(alignment: .center, spacing: 0) {
            DeadStatusCardFront(tank: tankPair[0]!)
                .frame(width: inch(5), height: inch(8))
                .border(.black, width: 1)
            if tankPair[1] != nil {
                DeadStatusCardFront(tank: tankPair[1]!)
                    .frame(width: inch(5), height: inch(8))
                    .border(.black, width: 1)
            } else {
                Rectangle()
                    .frame(width: inch(5), height: inch(8))
                    .foregroundColor(.white)
                    .border(.black, width: 1)
            }
        }))
        pages.append(AnyView(HStack(alignment: .center, spacing: 0) {
            if tankPair[1] != nil {
                DeadStatusCardBack(tank: tankPair[1]!)
                    .frame(width: inch(5), height: inch(8))
                    .border(.black, width: 1)
            } else {
                Rectangle()
                    .frame(width: inch(5), height: inch(8))
                    .foregroundColor(.white)
                    .border(.black, width: 1)
            }
            DeadStatusCardBack(tank: tankPair[0]!)
                .frame(width: inch(5), height: inch(8))
                .border(.black, width: 1)
        }
            .padding(.trailing, inch(doAlignmentCompensation ? 0.25 : 0))
            .padding(.bottom, inch(doAlignmentCompensation ? 0.1 : 0))
            .rotationEffect(Angle(degrees: doAlignmentCompensation ? -0.3 : 0))))
        
    }
    createAndSavePDF(from: pages, fileName: "Dead Status Cards")
}

func saveStatusCardsToPDF(_ tanks: [Tank], doAlignmentCompensation: Bool, showBorderWarning: Bool) {
    var workingTanks = tanks.filter({ !($0.doVirtualDelivery) })
    var pages: [AnyView] = []
    var tanksTwoByTwo: [[Tank?]] = []
    while true {
        if workingTanks.count > 1 {
            tanksTwoByTwo.append([workingTanks.removeFirst(), workingTanks.removeFirst()])
        } else if workingTanks.count == 1 {
            tanksTwoByTwo.append([workingTanks.removeFirst(), nil])
        } else {
            break
        }
    }
    for tankPair in tanksTwoByTwo {
        pages.append(AnyView(HStack(alignment: .center, spacing: 0) {
            StatusCardFront(tank: tankPair[0]!, showBorderWarning: showBorderWarning)
                .frame(width: inch(5), height: inch(8))
                .border(.black, width: 1)
            if tankPair[1] != nil {
                StatusCardFront(tank: tankPair[1]!, showBorderWarning: showBorderWarning)
                    .frame(width: inch(5), height: inch(8))
                    .border(.black, width: 1)
            } else {
                Rectangle()
                    .frame(width: inch(5), height: inch(8))
                    .foregroundColor(.white)
                    .border(.black, width: 1)
            }
        }))
        pages.append(AnyView(HStack(alignment: .center, spacing: 0) {
            if tankPair[1] != nil {
                tankPair[1]!.statusCardBack()
                    .frame(width: inch(5), height: inch(8))
                    .border(.black, width: 1)
            } else {
                Rectangle()
                    .frame(width: inch(5), height: inch(8))
                    .foregroundColor(.white)
                    .border(.black, width: 1)
            }
            tankPair[0]!.statusCardFront()
                .frame(width: inch(5), height: inch(8))
                .border(.black, width: 1)
        }
            .padding(.trailing, inch(doAlignmentCompensation ? 0.25 : 0))
            .padding(.bottom, inch(doAlignmentCompensation ? 0.1 : 0))
            .rotationEffect(Angle(degrees: doAlignmentCompensation ? -0.3 : 0))))
        
    }
    createAndSavePDF(from: pages, fileName: "Status Cards")
}

