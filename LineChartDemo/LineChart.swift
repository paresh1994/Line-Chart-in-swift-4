//
//  LineChart.swift
//  LineChartDemo
//
//  Created by iDeveloper2 on 24/07/18.
//  Copyright © 2018 iDeveloper2. All rights reserved.
//

import UIKit

struct PointEntry {
    let value: CGFloat
    let title: String
}

extension PointEntry: Comparable {
    static func <(lhs: PointEntry, rhs: PointEntry) -> Bool {
        return lhs.value < rhs.value
    }
    
    static func ==(lhs: PointEntry, rhs: PointEntry) -> Bool {
        return lhs.value == rhs.value
    }
}

class LineChart: UIView {

    /// gap between each point
    let lineGap: CGFloat = 60.0
    
    /// preseved space at top of the chart
    let topSpace: CGFloat = 40.0
    
    /// preserved space at bottom of the chart to show labels along the Y axis
    let bottomSpace: CGFloat = 40.0
    
    /// The top most horizontal line in the chart will be 10% higher than the highest value in the chart
    let topHorizontalLine: CGFloat = 110.0 / 100.0
    
    let circleDiameter: CGFloat = 5.0
    
    var dataEntries: [PointEntry]? {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /// Contains the main line which represents the data
    private let dataLayer: CALayer = CALayer()
    
    /// To show the gradient below the main line
    private let gradientLayer: CAGradientLayer = CAGradientLayer()
    
    /// Contains dataLayer and gradientLayer
    private let mainLayer: CALayer = CALayer()
    
    /// Contains mainLayer and label for each data entry
    private let scrollView: UIScrollView = UIScrollView()
    
    /// Contains horizontal lines
    private let gridLayer: CALayer = CALayer()
    
    /// An array of CGPoint on dataLayer coordinate system that the main line will go through. These points will be calculated from dataEntries array
    private var dataPoints: [CGPoint]?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        mainLayer.addSublayer(dataLayer)
        scrollView.layer.addSublayer(mainLayer)
        
        gradientLayer.colors = [#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.7).cgColor, UIColor.clear.cgColor]
        scrollView.layer.addSublayer(gradientLayer)
        self.layer.addSublayer(gridLayer)
        self.addSubview(scrollView)
        self.backgroundColor = #colorLiteral(red: 0, green: 0.3529411765, blue: 0.6156862745, alpha: 1)
    }
    
    override func layoutSubviews() {
        scrollView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        if let dataEntries = dataEntries {
            
            scrollView.contentSize = CGSize(width: CGFloat(dataEntries.count) * lineGap, height: self.frame.size.height)
            
            mainLayer.frame = CGRect(x: 0, y: 0, width: CGFloat(dataEntries.count) * lineGap, height: self.frame.size.height)
            
            dataLayer.frame = CGRect(x: 0, y: topSpace, width: mainLayer.frame.width, height: mainLayer.frame.height - topSpace - bottomSpace)
            
            gradientLayer.frame = dataLayer.frame
            dataPoints = convertDataEntriesToPoints(entries: dataEntries)
            gridLayer.frame = CGRect(x: 0, y: topSpace, width: self.frame.width, height: mainLayer.frame.height - topSpace - bottomSpace)
            
            clean()
            drawHorizontalLines()
            drawChart()
            maskGradientLayer()
            drawLabel()
        }
    }
    
    private func convertDataEntriesToPoints(entries: [PointEntry]) -> [CGPoint] {
        
        if let max = entries.max()?.value, let min = entries.min()?.value {
            
            var result = [CGPoint]()
            let minMaxrange: CGFloat = CGFloat(max - min) * topHorizontalLine
            
            for i in 0..<entries.count {
                let height: CGFloat = dataLayer.frame.height * (1 - ((CGFloat(entries[i].value) - CGFloat(min)) / minMaxrange))
                
                let point = CGPoint(x: CGFloat(i) * lineGap + 40, y: height)
                
                result.append(point)
            }
            return result
        }
        return []
    }
    
    private func drawChart() {
        if let path = createPath(), let point = dataPoints {
            let layer = CAShapeLayer()
            layer.path = path.cgPath
            layer.strokeColor = UIColor.white.cgColor
            layer.fillColor = UIColor.clear.cgColor
            self.dataLayer.addSublayer(layer)
            
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = 0
            animation.duration = 5
            layer.add(animation, forKey: "Myanimation")
           
            
            for i in point {
    
                var point = CGPoint(x: i.x, y: i.y)
                point.x -= circleDiameter / 2
                point.y -= circleDiameter / 2
                
                let circle = UIBezierPath(ovalIn: CGRect(origin: point, size: CGSize(width: circleDiameter, height: circleDiameter)))
                let circlelayer = CAShapeLayer()
                circlelayer.path = circle.cgPath
                circlelayer.fillColor = UIColor.white.cgColor
                circlelayer.strokeColor = UIColor.white.cgColor
                dataLayer.addSublayer(circlelayer)
            }
            
        }
    }
    
    private func createPath() -> UIBezierPath? {
        guard let entry = dataPoints, entry.count > 0 else {
            return nil
        }
        
        let path = UIBezierPath()
        path.move(to: entry[0])
        
        for i in 1..<entry.count {
            path.addLine(to: entry[i])
        }
        return path
    }
    
    private func maskGradientLayer() {
        if let entry = dataPoints, entry.count > 0 {
            
            let path = UIBezierPath()
            path.move(to: CGPoint(x: entry[0].x, y: dataLayer.frame.height))
            
            path.addLine(to: entry[0])

            if let createpath = createPath() {
                path.append(createpath)
            }
            
            path.addLine(to: CGPoint(x: entry[entry.count - 1].x, y: dataLayer.frame.height))
            path.addLine(to: CGPoint(x: entry[0].x, y: dataLayer.frame.height))
            
            let maskLayer = CAShapeLayer()
            maskLayer.path = path.cgPath
            maskLayer.fillColor = UIColor.white.cgColor
            maskLayer.strokeColor = UIColor.clear.cgColor
            maskLayer.lineWidth = 0.0
            
            gradientLayer.mask = maskLayer
        }
    }
    
    private func drawLabel() {
        if let entry = dataEntries, entry.count > 0 {
            
            for i in 0..<entry.count {
             
                let textLayer = CATextLayer()
                textLayer.frame = CGRect(x: lineGap*CGFloat(i) - lineGap/2 + 40, y: mainLayer.frame.size.height - bottomSpace/2 - 8, width: lineGap, height: 16)
                textLayer.foregroundColor = #colorLiteral(red: 0.5019607843, green: 0.6784313725, blue: 0.8078431373, alpha: 1).cgColor
                textLayer.backgroundColor = UIColor.clear.cgColor
                textLayer.alignmentMode = kCAAlignmentCenter
                textLayer.contentsScale = UIScreen.main.scale
                textLayer.fontSize = 11
                textLayer.string = entry[i].title
                mainLayer.addSublayer(textLayer)
            }
        }
    }
    
    private func drawHorizontalLines() {
        guard let dataEntries = dataEntries else {
            return
        }
        
        var gridValues: [CGFloat]? = nil
        if dataEntries.count < 4 && dataEntries.count > 0 {
            gridValues = [0, 1]
        } else if dataEntries.count >= 4 {
            gridValues = [0, 0.25, 0.5, 0.75, 1]
        }
        if let gridValues = gridValues {
            for value in gridValues {
                let height = value * gridLayer.frame.size.height
                
                let path = UIBezierPath()
                path.move(to: CGPoint(x: 0, y: height))
                path.addLine(to: CGPoint(x: gridLayer.frame.size.width, y: height))
                
                let lineLayer = CAShapeLayer()
                lineLayer.path = path.cgPath
                lineLayer.fillColor = UIColor.clear.cgColor
                lineLayer.strokeColor = #colorLiteral(red: 0.2784313725, green: 0.5411764706, blue: 0.7333333333, alpha: 1).cgColor
                lineLayer.lineWidth = 0.5
                if (value > 0.0 && value < 1.0) {
                    lineLayer.lineDashPattern = [4, 4]
                }
                
                gridLayer.addSublayer(lineLayer)
                
                var minMaxGap:CGFloat = 0
                var lineValue:Int = 0
                if let max = dataEntries.max()?.value,
                    let min = dataEntries.min()?.value {
                    minMaxGap = CGFloat(max - min) * topHorizontalLine
                    lineValue = Int((1-value) * minMaxGap) + Int(min)
                }
                
                let textLayer = CATextLayer()
                textLayer.frame = CGRect(x: 4, y: height, width: 50, height: 16)
                textLayer.foregroundColor = #colorLiteral(red: 0.5019607843, green: 0.6784313725, blue: 0.8078431373, alpha: 1).cgColor
                textLayer.backgroundColor = UIColor.clear.cgColor
                textLayer.contentsScale = UIScreen.main.scale
                textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
                textLayer.fontSize = 12
                textLayer.string = "\(lineValue)"
                
                gridLayer.addSublayer(textLayer)
            }
        }
    }
    
    
    private func clean() {
        mainLayer.sublayers?.forEach {
            if $0 is CATextLayer {
                $0.removeFromSuperlayer()
            }
        }
        dataLayer.sublayers?.forEach {$0.removeFromSuperlayer()}
        
        gridLayer.sublayers?.forEach {$0.removeFromSuperlayer()}
    }
    
}
