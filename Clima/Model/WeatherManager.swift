//
//  WeatherManager.swift
//  Clima
//
//  Created by Dylan Lin on 2/26/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    
    var delegate: WeatherManagerDelegate?
    
    let weatherURL =
    "https://api.openweathermap.org/data/2.5/weather?appid=b3551f9f32a0dfccebb473e30fdcfa7d&units=metric"
    
    let timeURL =
    "https://api.ipgeolocation.io/timezone?&apiKey=d17cd7d20e4d42cba3fe2cae37b627aa"
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString, urlType: "Weather")
    }
    
    func fetchWeather(latitude: Double, longitude: Double)
    {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString, urlType: "Weather")
    }
    
    func fetchTime(latitude: Double, longitude: Double)
    {
        let urlString = "\(timeURL)&lat=\(latitude)&long=\(longitude)"
        performRequest(with: urlString, urlType: "Time")
    }
    
    func performRequest(with urlString: String, urlType: String){
        //1. Create a URL
        if let url = URL(string: urlString)
        {
            //2. Create a URLSession
            let session = URLSession(configuration: .default)
            //3. Give the session a task
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil
                {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data
                {
                    if urlType == "Weather"
                    {
                        if let weather = self.parseJSON(safeData)
                        {
                            self.delegate?.didUpdateWeather(self, weather: weather)
                        }
                    }
                    else if urlType == "Time"
                    {
                        if let time = self.parseJSONTime(safeData)
                        {
                            self
                        }
                    }
                }
            }
            //4. Start the task
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data)->WeatherModel? {
        let decoder = JSONDecoder()
        do
        {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let name = decodedData.name
            let temperature = decodedData.main.temp
            
            let weatherModel = WeatherModel(conditionID: id, cityName: name, temperature: temperature)
            return weatherModel
            
        }catch
        {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    func parseJSONTime(_ timeData: Data)->String?
    {
        let decoder = JSONDecoder()
        do
        {
            let decodedData = try decoder.decode(TimeData.self, from: timeData)
            let time = decodedData.time_12
            return time
        }catch
        {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}
