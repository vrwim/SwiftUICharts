//
//  PathExtensions.swift
//  
//
//  Created by Will Dale on 10/02/2021.
//

import SwiftUI

// MARK: - Standard
extension Path {
    
    /// Draws straight lines between data points.
    static func straightLine<DP:CTStandardDataPointProtocol>(
        rect: CGRect,
        dataPoints: [DP],
        minValue: Double,
        range: Double,
        isFilled: Bool
    ) -> Path {
        let x : CGFloat = rect.width / CGFloat(dataPoints.count - 1)
        let y : CGFloat = rect.height / CGFloat(range)
        var path = Path()
        
        if dataPoints.count >= 2 {
            
            let firstPoint = CGPoint(x: 0,
                                     y: (CGFloat(dataPoints[0].value - minValue) * -y) + rect.height)
            path.move(to: firstPoint)
            
            for index in 1 ..< dataPoints.count {
                let nextPoint = CGPoint(x: CGFloat(index) * x,
                                        y: (CGFloat(dataPoints[index].value - minValue) * -y) + rect.height)
                
                path.addLine(to: nextPoint)
            }
            if isFilled {
                path.addLine(to: CGPoint(x: CGFloat(dataPoints.count-1) * x,  y: rect.height))
                path.addLine(to: CGPoint(x: 0, y: rect.height))
                path.closeSubpath()
            }
        }
        return path
    }
    
    /// Draws cubic Bézier curved lines between data points.
    static func curvedLine<DP:CTStandardDataPointProtocol>(
        rect: CGRect,
        dataPoints: [DP],
        minValue: Double,
        range: Double,
        isFilled: Bool
    ) -> Path {
        let x : CGFloat = rect.width / CGFloat(dataPoints.count - 1)
        let y : CGFloat = rect.height / CGFloat(range)
        var path = Path()
        
        let firstPoint = CGPoint(x: 0,
                                 y: (CGFloat(dataPoints[0].value - minValue) * -y) + rect.height)
        path.move(to: firstPoint)
        
        var previousPoint = firstPoint
        var lastIndex: Int = 0
        
        for index in 1 ..< dataPoints.count {
            let nextPoint = CGPoint(x: CGFloat(index) * x,
                                    y: (CGFloat(dataPoints[index].value - minValue) * -y) + rect.height)
            
            path.addCurve(to: nextPoint,
                          control1: CGPoint(x: previousPoint.x + (nextPoint.x - previousPoint.x) / 2,
                                            y: previousPoint.y),
                          control2: CGPoint(x: nextPoint.x - (nextPoint.x - previousPoint.x) / 2,
                                            y: nextPoint.y))
            lastIndex = index
            previousPoint = nextPoint
                        
        }
        if isFilled {
            path.addLine(to: CGPoint(x: CGFloat(lastIndex) * x,
                                     y: rect.height))
            path.addLine(to: CGPoint(x: 0,
                                     y: rect.height))
            path.closeSubpath()
        }
        return path
    }
    
    /// Draws straight lines between data points.
    static func straightLineBox<DP:CTRangedLineDataPoint>(
        rect: CGRect,
        dataPoints: [DP],
        minValue: Double,
        range: Double
    ) -> Path {
        let x : CGFloat = rect.width / CGFloat(dataPoints.count - 1)
        let y : CGFloat = rect.height / CGFloat(range)
        
        var path = Path()
        
        // Upper Path
        let firstPointUpper = CGPoint(x: 0,
                                      y: (CGFloat(dataPoints[0].upperValue - minValue) * -y) + rect.height)
        path.move(to: firstPointUpper)
        
        for indexUpper in 1 ..< dataPoints.count {
            let nextPointUpper = CGPoint(x: CGFloat(indexUpper) * x,
                                         y: (CGFloat(dataPoints[indexUpper].upperValue - minValue) * -y) + rect.height)
            path.addLine(to: nextPointUpper)
        }
        
        // Lower Path
        for indexLower in (0 ..< dataPoints.count).reversed() {
            let nextPointLower = CGPoint(x: CGFloat(indexLower) * x,
                                         y: (CGFloat(dataPoints[indexLower].lowerValue - minValue) * -y) + rect.height)
            
            path.addLine(to: nextPointLower)
            
        }
        
        path.addLine(to: firstPointUpper)
        
        return path
    }
    
    /// Draws straight lines between data points.
    static func curvedLineBox<DP:CTRangedLineDataPoint>(
        rect: CGRect,
        dataPoints: [DP],
        minValue: Double,
        range: Double
    ) -> Path {
        let x : CGFloat = rect.width / CGFloat(dataPoints.count - 1)
        let y : CGFloat = rect.height / CGFloat(range)
        
        var path = Path()
        
        // Upper Path
        let firstPointUpper = CGPoint(x: 0,
                                      y: (CGFloat(dataPoints[0].upperValue - minValue) * -y) + rect.height)
        path.move(to: firstPointUpper)
        
        var previousPoint = firstPointUpper
        
        for indexUpper in 1 ..< dataPoints.count {
            let nextPoint = CGPoint(x: CGFloat(indexUpper) * x,
                                    y: (CGFloat(dataPoints[indexUpper].upperValue - minValue) * -y) + rect.height)
            
            path.addCurve(to: nextPoint,
                          control1: CGPoint(x: previousPoint.x + (nextPoint.x - previousPoint.x) / 2,
                                            y: previousPoint.y),
                          control2: CGPoint(x: nextPoint.x - (nextPoint.x - previousPoint.x) / 2,
                                            y: nextPoint.y))
            previousPoint = nextPoint
        }
        
        // Lower Path
        for indexLower in (0 ..< dataPoints.count).reversed() {
            let nextPoint = CGPoint(x: CGFloat(indexLower) * x,
                                    y: (CGFloat(dataPoints[indexLower].lowerValue - minValue) * -y) + rect.height)
            
            path.addCurve(to: nextPoint,
                          control1: CGPoint(x: previousPoint.x + (nextPoint.x - previousPoint.x) / 2,
                                            y: previousPoint.y),
                          control2: CGPoint(x: nextPoint.x - (nextPoint.x - previousPoint.x) / 2,
                                            y: nextPoint.y))
            previousPoint = nextPoint
        }
        
        path.addLine(to: firstPointUpper)
        
        return path
    }
}

// MARK: - Ignore Zero
extension Path {
    /// Draws straight lines between data points ignoring any values of zero.
    static func straightLineIgnoreZero<DP:CTStandardDataPointProtocol>(
        rect: CGRect,
        dataPoints: [DP],
        minValue: Double,
        range: Double,
        isFilled: Bool
    ) -> Path {
        let x : CGFloat = rect.width / CGFloat(dataPoints.count - 1)
        let y : CGFloat = rect.height / CGFloat(range)
        var path = Path()
        
        if dataPoints.count >= 2 {
            
            findFirst: for index in 0 ..< dataPoints.count {
                if dataPoints[index].value != 0 {
                    let firstPoint = CGPoint(x: CGFloat(index) * x,
                                             y: (CGFloat(dataPoints[index].value - minValue) * -y) + rect.height)
                    path.move(to: firstPoint)
                    break findFirst
                }
            }
            
            for index in 1 ..< dataPoints.count {
                let nextPoint = CGPoint(x: CGFloat(index) * x,
                                        y: (CGFloat(dataPoints[index].value - minValue) * -y) + rect.height)
                
                if dataPoints[index].value != 0 {
                    path.addLine(to: nextPoint)
                }
                
            }
            if isFilled {
                path.addLine(to: CGPoint(x: CGFloat(dataPoints.count-1) * x,  y: rect.height))
                path.addLine(to: CGPoint(x: 0, y: rect.height))
                path.closeSubpath()
            }
        }
        return path
    }
    
    /// Draws cubic Bézier curved lines between data points.
    static func curvedLineIgnoreZero<DP:CTStandardDataPointProtocol>(
        rect: CGRect,
        dataPoints: [DP],
        minValue: Double,
        range: Double,
        isFilled: Bool
    ) -> Path {
        let x : CGFloat = rect.width / CGFloat(dataPoints.count - 1)
        let y : CGFloat = rect.height / CGFloat(range)
        var path = Path()
        
        var firstPoint: CGPoint = .zero
        
        findFirst: for index in 0 ..< dataPoints.count {
            if dataPoints[index].value != 0 {
                firstPoint = CGPoint(x: 0,
                                     y: (CGFloat(dataPoints[0].value - minValue) * -y) + rect.height)
                path.move(to: firstPoint)
                break findFirst
            }
        }
        
        var previousPoint = firstPoint
        var lastIndex : Int = 0
        
        
        for index in 1 ..< dataPoints.count {
            let nextPoint = CGPoint(x: CGFloat(index) * x,
                                    y: (CGFloat(dataPoints[index].value - minValue) * -y) + rect.height)
            
            if dataPoints[index].value != 0 {
                path.addCurve(to: nextPoint,
                              control1: CGPoint(x: previousPoint.x + (nextPoint.x - previousPoint.x) / 2,
                                                y: previousPoint.y),
                              control2: CGPoint(x: nextPoint.x - (nextPoint.x - previousPoint.x) / 2,
                                                y: nextPoint.y))
                previousPoint = nextPoint
            }
            lastIndex = index
            
        }
        if isFilled {
            path.addLine(to: CGPoint(x: CGFloat(lastIndex) * x,
                                     y: rect.height))
            path.addLine(to: CGPoint(x: 0,
                                     y: rect.height))
            path.closeSubpath()
        }
        return path
    }
    
    /// Draws straight lines between data points.
    static func straightLineBoxIgnoreZero<DP:CTRangedLineDataPoint>(
        rect: CGRect,
        dataPoints: [DP],
        minValue: Double,
        range: Double
    ) -> Path {
        let x : CGFloat = rect.width / CGFloat(dataPoints.count - 1)
        let y : CGFloat = rect.height / CGFloat(range)
        
        var path = Path()
        
        // Upper Path
        let firstPointUpper = CGPoint(x: 0,
                                      y: (CGFloat(dataPoints[0].upperValue - minValue) * -y) + rect.height)
        path.move(to: firstPointUpper)
        
        for indexUpper in 1 ..< dataPoints.count {
            let nextPointUpper = CGPoint(x: CGFloat(indexUpper) * x,
                                         y: (CGFloat(dataPoints[indexUpper].upperValue - minValue) * -y) + rect.height)
            
            if dataPoints[indexUpper].value != 0 {
                path.addLine(to: nextPointUpper)
            }
        }
        
        // Lower Path
        for indexLower in (0 ..< dataPoints.count).reversed() {
            let nextPointLower = CGPoint(x: CGFloat(indexLower) * x,
                                         y: (CGFloat(dataPoints[indexLower].lowerValue - minValue) * -y) + rect.height)
            
            if dataPoints[indexLower].value != 0 {
                path.addLine(to: nextPointLower)
            }
        }
        
        path.addLine(to: firstPointUpper)
        
        return path
    }
    
    /// Draws straight lines between data points.
    static func curvedLineBoxIgnoreZero<DP:CTRangedLineDataPoint>(
        rect: CGRect,
        dataPoints: [DP],
        minValue: Double,
        range: Double
    ) -> Path {
        let x : CGFloat = rect.width / CGFloat(dataPoints.count - 1)
        let y : CGFloat = rect.height / CGFloat(range)
        
        var path = Path()
        
        // Upper Path
        let firstPointUpper = CGPoint(x: 0,
                                      y: (CGFloat(dataPoints[0].upperValue - minValue) * -y) + rect.height)
        path.move(to: firstPointUpper)
        
        var previousPoint = firstPointUpper
        
        for indexUpper in 1 ..< dataPoints.count {
            
            let nextPoint = CGPoint(x: CGFloat(indexUpper) * x,
                                    y: (CGFloat(dataPoints[indexUpper].upperValue - minValue) * -y) + rect.height)
            
            if dataPoints[indexUpper].value != 0 {
                path.addCurve(to: nextPoint,
                              control1: CGPoint(x: previousPoint.x + (nextPoint.x - previousPoint.x) / 2,
                                                y: previousPoint.y),
                              control2: CGPoint(x: nextPoint.x - (nextPoint.x - previousPoint.x) / 2,
                                                y: nextPoint.y))
                previousPoint = nextPoint
            }
        }
        
        // Lower Path
        for indexLower in (0 ..< dataPoints.count).reversed() {
            let nextPoint = CGPoint(x: CGFloat(indexLower) * x,
                                    y: (CGFloat(dataPoints[indexLower].lowerValue - minValue) * -y) + rect.height)
            
            if dataPoints[indexLower].value != 0 {
                path.addCurve(to: nextPoint,
                              control1: CGPoint(x: previousPoint.x + (nextPoint.x - previousPoint.x) / 2,
                                                y: previousPoint.y),
                              control2: CGPoint(x: nextPoint.x - (nextPoint.x - previousPoint.x) / 2,
                                                y: nextPoint.y))
                previousPoint = nextPoint
            }
            
        }
        
        path.addLine(to: firstPointUpper)
        
        return path
        
    }
}
