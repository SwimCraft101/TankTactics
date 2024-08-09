//
//  StatusCard.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 8/9/24.
//

import SwiftUI
import AppKit
import PDFKit

extension View {
    func asNSImage(size: NSSize) -> NSImage? {
        // Create the hosting controller with the SwiftUI view
        let hostingView = NSHostingView(rootView: self)
        hostingView.frame = NSRect(origin: .zero, size: size)
        
        // Create a bitmap representation with the desired size and scale
        guard let bitmapRep = hostingView.bitmapImageRepForCachingDisplay(in: hostingView.bounds) else {
            return nil
        }
        
        hostingView.cacheDisplay(in: hostingView.bounds, to: bitmapRep)
        
        // Create an NSImage from the bitmap representation
        let nsImage = NSImage(size: size)
        nsImage.addRepresentation(bitmapRep)
        
        return nsImage
    }
}

func createPDFData(from images: [NSImage]) -> Data? {
    guard !images.isEmpty else { return nil }
    
    // Create a PDFDocument instance
    let pdfDocument = PDFDocument()

    for image in images {
        // Create a PDFPage from NSImage
        if let pdfPage = PDFPage(image: image) {
            // Add the page to the PDF document
            pdfDocument.insert(pdfPage, at: pdfDocument.pageCount)
        }
    }
    // Return the PDF data
    return pdfDocument.dataRepresentation()
}

func printPDFData(_ pdfData: Data) {
    // Create a PDF document from the data
    guard let pdfDocument = PDFDocument(data: pdfData) else {
        print("Failed to create PDF document from data.")
        return
    }
    
    // Create a print view with the PDF document
    let printView = PDFView(frame: NSRect(x: 0, y: 0, width: 400, height: 400))
    printView.document = pdfDocument

    // Create a print operation
    let printOperation = NSPrintOperation(view: printView)
    
    // Set the print info if needed
    let printInfo = printOperation.printInfo
    printInfo.jobDisposition = .preview // or .print for actual printing
    printInfo.orientation = .portrait
    printInfo.paperSize = NSSize(width: 5.5 * 72, height: 8.5 * 72)
    // Present the print dialog
    printOperation.run()
}

struct StatusCardFront: View {
    let tank: Tank
    var body: some View {
        ZStack {
            Image("Status Card Front")
                .scaledToFill()
        }
    }
}

struct StatusCardBack: View {
    let tank: Tank
    var body: some View {
        ZStack {
            Image("Status Card Back")
                .scaledToFill()
        }
    }
}

func printStatusCard(_ tank: Tank) {
    let statusCardFront = StatusCardFront(tank: tank).asNSImage(size: NSSize(width: 5.5, height: 8.5))!
    let statusCardBack  = StatusCardBack(tank:  tank).asNSImage(size: NSSize(width: 5.5, height: 8.5))!
    printPDFData(createPDFData(from: [statusCardFront, statusCardBack])!)
}

#Preview {
    HSplitView {
        StatusCardFront(tank: board.objects.first as! Tank)
        StatusCardBack(tank: board.objects.first as! Tank)
    }
}
