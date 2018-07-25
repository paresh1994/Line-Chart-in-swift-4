//
//  ViewController.swift
//  LineChartDemo
//
//  Created by iDeveloper2 on 24/07/18.
//  Copyright © 2018 iDeveloper2. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var lineChartView: LineChart!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dataEntries = generateRandomEntries()
        
        lineChartView.dataEntries = dataEntries
        
        self.view.backgroundColor = #colorLiteral(red: 0, green: 0.3529411765, blue: 0.6156862745, alpha: 1)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    private func generateRandomEntries() -> [PointEntry] {
        var result: [PointEntry] = []
        for i in 0..<25 {
            let value = Int(arc4random() % 100)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM"
            var date = Date()
            date.addTimeInterval(TimeInterval(24*60*60*i))
            
            result.append(PointEntry(value: CGFloat(value), title: formatter.string(from: date)))
        }
        return result
    }

}

