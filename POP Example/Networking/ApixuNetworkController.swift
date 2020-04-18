import Foundation

private enum API {
    static let key = "82a76d10fb31f56df261c371d8d5367d"
}

final class ApixuNetworkController: NetworkController {
    
    
    public var tempUnit: TemperatureUnit = .imperial
    
    let backupController: NetworkController?
    
    public init(backupController: NetworkController? = nil) {
        self.backupController = backupController
    }
    
    func fetchCurrentWeatherData(city: String, completionHandler: @escaping (WeatherData?, Error?) -> Void) {
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        //http://api.weatherstack.com/current?access_key=82a76d10fb31f56df261c371d8d5367d&query=New%20York
        
        let endpoint = "http://api.weatherstack.com/current?access_key=\(API.key)&query=\(city)"
        
        let safeURLString = endpoint.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        guard let endpointURL = URL(string: safeURLString) else {
            completionHandler(nil, NetworkControllerError.InvalidURL(safeURLString))
            return
        }
        
        let dataTask = session.dataTask(with: endpointURL, completionHandler: { (data, response, error) -> Void in
            guard error == nil else {
                completionHandler(nil, NetworkControllerError.forwarded(error!))
                return
            }
            guard let responseData = data else {
                completionHandler(nil, NetworkControllerError.InvalidPayload(endpointURL))
                return
            }
            
            // decode json
            self.decode(jsonData: responseData, endpointURL: endpointURL, completionHandler: completionHandler)
        })
        
        dataTask.resume()
    }
    
    private func decode(jsonData: Data, endpointURL: URL, completionHandler: @escaping (WeatherData?, NetworkControllerError?) -> Void) {
        let decoder = JSONDecoder()
        do {
            let weatherContainer = try decoder.decode(ApixuWeatherContainer.self, from: jsonData)
            let weatherInfo = weatherContainer.current
            
            var temp: Float
            
            switch self.tempUnit {
            case .imperial:
                temp = Float(weatherInfo.temperature)
            case .scientific:
                temp = 0
            case .matric:
                temp = 0
            }
            
            let weatherData = WeatherData(temperature: temp, condition: weatherInfo.observation_time, unit: self.tempUnit)
            completionHandler(weatherData, nil)
        } catch let error {
            completionHandler(nil, NetworkControllerError.forwarded(error))
        }
    }
}
