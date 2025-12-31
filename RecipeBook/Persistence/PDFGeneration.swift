//
//  PDFGeneration.swift
//  RecipeBook
//
//  Created by Alexandra Paras on 12/29/25.
//

import SwiftUI
import CoreGraphics
import CoreFoundation

let pdfPageBounds = CGRect(x: 0, y: 0, width: 612 * 1.5, height: 792 * 1.5) // US Letter size

@MainActor
func generateMultiPagePDF(from view: some View, fileName: String) -> URL? {
    var pdfPageBounds = pdfPageBounds
    
    // Create a URL for the PDF file
    let tempDirectory = FileManager.default.temporaryDirectory
    let pdfURL = tempDirectory.appendingPathComponent(fileName).appendingPathExtension("pdf")
    
    // Create the size of the pdf page and the size that you want to draw within
    let margin: CGFloat = 72
    let printableRect = CGRect(x: margin,
                               y: margin,
                               width: pdfPageBounds.width,
                               height: pdfPageBounds.height - (2 * margin))
    var mediaBox = CGRect(origin: .zero, size: pdfPageBounds.size)
    
    // Create the PDF context
    guard let pdfContext = CGContext(pdfURL as CFURL, mediaBox: &mediaBox, nil) else {
        return nil
    }
    
    // Use ImageRenderer to render the view to calculate the total height
    let renderer = ImageRenderer(content: view)
    renderer.isOpaque = false
    
    var totalHeight: CGFloat = 0
    renderer.render { size, _ in
        totalHeight = size.height
    }
    
    // Loop to render content page by page
    var pageStart: CGFloat = 0
    while abs(pageStart) < totalHeight {
        pdfContext.beginPDFPage(nil) // Start a new page
        
        // Translate the context up by the 'pageStart' amount to draw the next section
        let margin: CGFloat = 72.0
        var offset: Int = 0
        if totalHeight > printableRect.height {
            if totalHeight > pdfPageBounds.height {
                offset = Int(totalHeight) % Int(pdfPageBounds.height)
            } else if totalHeight > printableRect.height {
                offset = Int(totalHeight) - Int(pdfPageBounds.height) // should be negative
            }
            pdfContext.clip(to: printableRect)
            pdfContext.translateBy(x: 0, y: -CGFloat(offset) - margin - pageStart)
        } else {
            pdfContext.translateBy(x: 0, y: pdfPageBounds.height - totalHeight - margin)
        }
        
        // Render the view into the current context
        renderer.render { _, ctx in
            ctx(pdfContext)
        }
        
        pdfContext.endPDFPage() // End the page
        
        // Move to the next page's starting point
        pageStart -= printableRect.height
    }
    
    pdfContext.closePDF()
    return pdfURL
}
