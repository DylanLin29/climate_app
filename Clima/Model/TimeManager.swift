//
//  TimeManager.swift
//  Clima
//
//  Created by Dylan Lin on 3/1/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation

protocol TimeManagerDelegate
{
    func didUpdateTime(_ timeManager: TimeManager, time: String)
    func didTimeFailWithError(error: Error)
}

struct TimeManager {
    
    var delegate: TimeManagerDelegate?
    let timeLongLatURL = "https://api.ipgeolocation.io/timezone?&apiKey=d17cd7d20e4d42cba3fe2cae37b627aa"
    
    func fetchTime(latitude: Double, longitude: Double)
    {
        let urlString = "\(timeLongLatURL)&lat=\(latitude)&long=\(longitude)"
        performRequest(with: urlString)
    }

    func performRequest(with urlString: String){
        //1. Create a URL
        if let url = URL(string: urlString)
        {
            //2. Create a URLSession
            let session = URLSession(configuration: .default)
            //3. Give the session a task
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil
                {
                    self.delegate?.didTimeFailWithError(error: error!)
                    return
                }
                if let safeData = data
                {
                    if let time = self.parseJSON(safeData)
                    {
                        self.delegate?.didUpdateTime(self, time: time)
                    }
                }
             }
            //4. Start the task
            task.resume()
        }
    }

    func parseJSON(_ timeData: Data)->String?
    {
        let decoder = JSONDecoder()
        do
        {
            let decodedData = try decoder.decode(TimeData.self, from: timeData)
            let time = decodedData.time_12
            return String(time.suffix(2))
        }catch
        {
            delegate?.didTimeFailWithError(error: error)
            return nil
        }
    }

}
