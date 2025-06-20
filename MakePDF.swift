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

func saveDeadStatusCardsToPDF(_ tanks: [DeadTank], doAlignmentCompensation: Bool) {
    runGameTick()
    var workingTanks = tanks.filter({ $0.virtualDelivery == nil })
    var pages: [AnyView] = []
    var tanksTwoByTwo: [[DeadTank?]] = []
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
    var workingTanks = tanks.filter({ $0.virtualDelivery == nil && !($0.science) })
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
            StatusCardFront(tank: tankPair[0]!)
                .frame(width: inch(5), height: inch(8))
                .border(.black, width: 1)
            if tankPair[1] != nil {
                StatusCardFront(tank: tankPair[1]!)
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
                StatusCardBack(tank: tankPair[1]!, showBorderWarning: showBorderWarning)
                    .frame(width: inch(5), height: inch(8))
                    .border(.black, width: 1)
            } else {
                Rectangle()
                    .frame(width: inch(5), height: inch(8))
                    .foregroundColor(.white)
                    .border(.black, width: 1)
            }
            StatusCardBack(tank: tankPair[0]!, showBorderWarning: showBorderWarning)
                .frame(width: inch(5), height: inch(8))
                .border(.black, width: 1)
        }
            .padding(.trailing, inch(doAlignmentCompensation ? 0.25 : 0))
            .padding(.bottom, inch(doAlignmentCompensation ? 0.1 : 0))
            .rotationEffect(Angle(degrees: doAlignmentCompensation ? -0.3 : 0))))
        
    }
    createAndSavePDF(from: pages, fileName: "Status Cards")
}

