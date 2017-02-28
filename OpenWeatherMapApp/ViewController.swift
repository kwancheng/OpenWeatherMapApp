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
    @IBOutlet weak var btnFetch: UIButton!
    @IBOutlet weak var indFetching: UIActivityIndicatorView!
    @IBOutlet weak var panelWeatherIcon: UIView!
    @IBOutlet weak var weatherDump: UITextView!
    @IBOutlet weak var panelWeatherInfo: UIView!
    
    private let owm = OpenWeatherMap() // TODO: User Configurable at some point, need refactoring is we do
    fileprivate var isFetching : Bool = false {
        willSet(fetching) {
            if fetching {
                btnFetch.isEnabled = false
                btnFetch.setTitle("", for: UIControlState.normal)
                indFetching.startAnimating()
            } else {
                btnFetch.isEnabled = true
                btnFetch.setTitle("Fetch", for: UIControlState.normal)
                indFetching.hidesWhenStopped = true
                indFetching.stopAnimating()
            }
        }
    }
    
    fileprivate var hasWeatherInfo : Bool = false {
        willSet(hasWeather) {
            isFetching = false // just in case
            if hasWeather {
                panelWeatherInfo.isHidden = false
            } else {
                panelWeatherInfo.isHidden = true
            }
        }
    }
    
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
        
        do {
            isFetching = true
            try owm.getWeather(for: cleanedQueryParams[0], and: cleanedQueryParams.count>1 ? cleanedQueryParams[1] : nil)
        } catch {
            if let owmError = error as? OpenWeatherMapError {
                switch owmError {
                    case .failure(let msg): break // TODO: SHOW ERROR
                    // future proof
                }
            } else {
                // TODO: SHOW General Error
            }
        }
    }
}

extension ViewController : OpenWeatherMapDelegate {
    public func hasWeatherData(weather:WeatherResponse) {
        isFetching = false
        hasWeatherInfo = true
        weatherDump.text = "\(weather)"
    }
    
    public func failedToQueryWeather(response: URLResponse?, error: Error?, otherMsg: String?) {
        isFetching = false
        hasWeatherInfo = false
        // TODO : Show error
    }
}
