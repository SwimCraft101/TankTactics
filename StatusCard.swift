//
//  StatusCard.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 8/9/24.
//

import SwiftUI
import AppKit
import PDFKit

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
    let pageSize = CGSize(width: 396, height: 612) // 5.5 by 8.5 inches in points (72 points per inch)
    
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

func saveStatusCardsToPDF(_ tanks: [Tank]) {
    var pages: [AnyView] = []
    for tank in tanks {
        pages.append(AnyView(StatusCardFront(tank: tank)))
        pages.append(AnyView(StatusCardBack(tank: tank)))
    }
    createAndSavePDF(from: pages)
}

#Preview {
    HSplitView {
        StatusCardFront(tank: exampleTank)
        StatusCardBack(tank: exampleTank)
    }
}
