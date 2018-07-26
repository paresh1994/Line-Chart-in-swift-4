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
        lineChartView.layer.cornerRadius = 10.0
        self.view.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    private func generateRandomEntries() -> [PointEntry] {
        let results = [PointEntry(value: 30.0, title: "One"),
                       PointEntry(value: 45.0, title: "Two"),
                       PointEntry(value: 15.0, title: "Three"),
                       PointEntry(value: 10.0, title: "Four"),
                       PointEntry(value: 75.0, title: "Five"),
                       PointEntry(value: 85.0, title: "Sixe")]
        return results
    }

}

