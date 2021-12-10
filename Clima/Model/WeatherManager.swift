//
//  WeatherManager.swift
//  Clima
//
//  Created by doyun on 2021/08/02.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate{
    func didUpdateWeather(_ weatherManager:WeatherManager, weather:WeatherModel)
    func didFailWithError(error:Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=542a144917ecbf7680ca48ae41dad1df&units=metric"
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName:String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        self.performRequest(with:urlString)
    }
    
    func fetchWeather(latitude:CLLocationDegrees,longitude:CLLocationDegrees) {
        let urlString = "\(weatherURL)&lon=\(longitude)&lat=\(latitude)"
        self.performRequest(with:urlString)
    }
    
    func performRequest(with urlString:String) {
        //1.create a URL
        if let url = URL(string: urlString) {
            //2.create a URLSession
            let session = URLSession(configuration: .default)
            //3. Give the session Task
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeDate = data {
                    if let weather = self.parseJSON(weatherData: safeDate) {
                        self.delegate?.didUpdateWeather(self,weather: weather)
                    }
                }
            }
            task.resume()
        }
    }
    func parseJSON(weatherData:Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId:id,cityName:name,temperature:temp)
            return weather
        } catch {
            self.delegate?.didFailWithError(error: error)
            print(error)
            return nil
        }
    }
    
}
