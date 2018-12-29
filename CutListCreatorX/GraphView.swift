//
//  GraphView.swift
//  CutListCreatorX
//
//  Created by Jens Brauer on 22.12.18.
//  Copyright © 2018 Jens Brauer. All rights reserved.
//

import Cocoa

class GraphView: NSView {
    
    var numberOfCuts = 0 {didSet {needsDisplay = true}}
    var cuts = [Double]()
    var duration = 0.0
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        // Simple
        //NSColor.white.setFill()
        //NSRectFill(bounds)
        
        //Advanced
        let context = NSGraphicsContext.current()?.cgContext
        drawBarGraphInContext(context: context)
    }
    
}

//Drawing extension
extension GraphView {
    func drawRoundedRect(rect: CGRect, inContext context: CGContext?,
                         radius: CGFloat, borderColor: CGColor, fillColor: CGColor) {
        // Create Mutable path
        let path = CGMutablePath()
        
        // Form the rounded rectangle path, following these steps:
        // Move to the center point at the bottom of the rectangle.
        // Add the lower line segment at the bottom-right corner using addArc(tangent1End:tangent2End:radius). This method draws the horizontal line and the rounded corner.
        // Add the right line segment and the top-right corner.
        // Add the top line segment and the top-left corner.
        // Add the right line segment and the bottom-left corner.
        // Close the path, which adds a line from the last point to the starter point.
        path.move( to: CGPoint(x:  rect.midX, y:rect.minY ))
        path.addArc( tangent1End: CGPoint(x: rect.maxX, y: rect.minY ),
                     tangent2End: CGPoint(x: rect.maxX, y: rect.maxY), radius: radius)
        path.addArc( tangent1End: CGPoint(x: rect.maxX, y: rect.maxY ),
                     tangent2End: CGPoint(x: rect.minX, y: rect.maxY), radius: radius)
        path.addArc( tangent1End: CGPoint(x: rect.minX, y: rect.maxY ),
                     tangent2End: CGPoint(x: rect.minX, y: rect.minY), radius: radius)
        path.addArc( tangent1End: CGPoint(x: rect.minX, y: rect.minY ),
                     tangent2End: CGPoint(x: rect.maxX, y: rect.minY), radius: radius)
        path.closeSubpath()
        
        // Set LineWidth and Colors
        context?.setLineWidth(1.0)
        context?.setFillColor(fillColor)
        context?.setStrokeColor(borderColor)
        
        // Add path to context and draw
        context?.addPath(path)
        context?.drawPath(using: .fillStroke)
    }
    
    func drawBarGraphInContext(context: CGContext?) {
        let barChartRect = barChartRectangle() //needs to be defined
        drawRoundedRect(rect: barChartRect, inContext: context,
                        radius: 1,
                        borderColor: CGColor.black,
                        fillColor: CGColor.black)
        
        // Clipping: Set the Cuts
        if numberOfCuts > 0 {
        var clipRect = barChartRect
        // Loop over all cuts
        for index in 0..<numberOfCuts+1 {
            // Calculate percentage width
            var clipWidth=barChartRect.width
            if index == 0 { clipWidth=barChartRect.width * CGFloat((cuts[index])/duration)}
            else if index == numberOfCuts { clipWidth = barChartRect.width * CGFloat((duration-cuts[index-1])/duration) }
            else{ clipWidth = barChartRect.width * CGFloat((cuts[index]-cuts[index-1])/duration)}
            clipRect.size.width = clipWidth
            
            // Saves the state of the context
            context?.saveGState()
            // set the clipping area
            context?.clip(to: clipRect)
            
            // draw the rectangle
            let fileTypeColors = index%2==0 ? CGColor.init(red: 1, green: 0, blue: 0, alpha: 1) : CGColor.init(red: 0, green: 1, blue: 0, alpha: 1)
            drawRoundedRect(rect: barChartRect, inContext: context,
                            radius: 1,
                            borderColor: CGColor.black,
                            fillColor: fileTypeColors)
            
            //restores the state of the context.
            context?.restoreGState()
            
            // Move the x origin of the clipping rect before the next iteration
            clipRect.origin.x = clipRect.maxX
        }
        }
    }
    
}

extension GraphView {
    //Rounded Rectangle Position
    func barChartRectangle() -> CGRect {
        let width = bounds.size.width;
        let height = bounds.size.height;
        let rect = CGRect(x: 0,
                          y: 0,
                          width: width, height: height)
        return rect
    }
}
