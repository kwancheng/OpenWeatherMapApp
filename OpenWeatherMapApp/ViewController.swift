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
    @IBOutlet weak var weatherDump: UITextView!
    @IBOutlet weak var panelWeatherInfo: UIView!
    @IBOutlet weak var img: UIImageView!
    
    fileprivate let owm = OpenWeatherMap(apiKey : nil) // TODO: User Configurable at some point, need refactoring is we do
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
    
    fileprivate var weatherInfo : WeatherResponse? = nil {
        willSet(newWeatherInfo) {
            isFetching = false // just in case
            if newWeatherInfo != nil {
                panelWeatherInfo.isHidden = false
                weatherDump.text = "\(newWeatherInfo!)"
                img.image = UIImage(named: "refresh-icon")
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
    
    fileprivate func showAlert(msg : String) {
        let alert = UIAlertController(title: "Error", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:
        { action in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func fetchWeatherTouched(_ sender: UIButton) {
        guard let components = tfCityCountry.text?.components(separatedBy: ",") else {
            showAlert(msg: "Must Enter A Search String")
            return
        }

        guard components.count >= 1 else {
            showAlert(msg: "Must Enter A Search String")
            return
        }
        
        let cleanedQueryParams = components.map { (element) -> String in
            return element.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // one more check
        for element in cleanedQueryParams {
            if element.characters.count == 0 {
                showAlert(msg: "Must Enter A Search String")
                return
            }
        }
        
        do {
            isFetching = true
            weatherInfo = nil
            try owm.getWeather(for: cleanedQueryParams[0], and: cleanedQueryParams.count>1 ? cleanedQueryParams[1] : nil)
        } catch {
            if let owmError = error as? OpenWeatherMapError {
                switch owmError {
                    case .failure(let msg):
                        showAlert(msg: msg)
                }
            } else {
                showAlert(msg: "Error Fetching \(error.localizedDescription)")
            }
        }
    }
}

extension ViewController : OpenWeatherMapDelegate {
    public func hasWeatherData(weather:WeatherResponse) {
        isFetching = false
        weatherInfo = weather
        
        if let iconId = weatherInfo?.weathers?[0].icon {
            do {
                try owm.getThumnail(id: iconId)
            } catch {
                img.image = UIImage(named: "file-broken-icon")
            }
        } else {
            img.image = UIImage(named: "file-broken-icon")
        }
    }
    
    public func failedToQueryWeather(response: URLResponse?, error: Error?, otherMsg: String?) {
        isFetching = false
        weatherInfo = nil
        showAlert(msg: "Query Failed \(otherMsg)")
    }
    
    func hasThumbnailData(image: UIImage, id : String) {
        guard let iconId = weatherInfo?.weathers?[0].icon else {
            return
        }
        
        if iconId.caseInsensitiveCompare(id) == .orderedSame {
            img.image = image
        }
    }
    
    func failedToGetThumbnail(response: URLResponse?, error: Error?, otherMsg: String?) {
        img.image = UIImage(named: "file-broken-icon")
    }
}
