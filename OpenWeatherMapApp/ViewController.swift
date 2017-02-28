//
//  ViewController.swift
//  OpenWeatherMapApp
//
//  Created by Cheng, Yu Kwan on 2/28/17.
//  Copyright © 2017 GhengisKwan. All rights reserved.
//

import UIKit
import OpenWeatherMapApi

class ViewController: UIViewController {
    @IBOutlet weak var tfCityCountry: UITextField!
    private let owm = OpenWeatherMap() // TODO: User Configurable at some point, need refactoring is we do
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        owm.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func fetchWeatherTouched(_ sender: UIButton) {
        guard let components = tfCityCountry.text?.components(separatedBy: ",") else {
            // TODO : SHOW ERROR! probably forgot to enter something, components returns empty array
            return
        }

        guard components.count >= 1 else {
            // TODO : SHOW ERROR! Empty String don't count
            return
        }
        
        let cleanedQueryParams = components.map { (element) -> String in
            return element.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // one more check
        for element in cleanedQueryParams {
            if element.characters.count == 0 {
                // TODO : SHOW ERROR! can't have empty
                return
            }
        }
        
        owm.getWeather(for: cleanedQueryParams[0], and: cleanedQueryParams.count>1 ? cleanedQueryParams[1] : nil)
    }
}

extension ViewController : OpenWeatherMapDelegate {
    public func hasWeatherData(weather:WeatherResponse) {
    }
    
    public func failedToQueryWeather(response: URLResponse?, error: Error?, otherMsg: String?) {
        print("URL - \(response?.url)")
    }
}
