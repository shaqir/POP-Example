import Foundation

private enum API {
    static let key = "42a0b8c5b3ba29c4c65332d2808ccb88"
}

final class OpenWeatherMapNetworkController : NetworkController{
   
    var backupController: NetworkController?
    
    init(backupController: NetworkController? = nil) {
        self.backupController = backupController
    }
    
    public var tempUnit: TemperatureUnit = .imperial
    
    //Fake simulation to get error
    func simulateError() -> NetworkControllerError?{
        return nil
        //return .forwarded(NSError(domain: "OpenWeatherMapNetworkController", code: -1, userInfo: nil))
    }
    
    func fetchCurrentWeatherData(city: String, completionHandler: @escaping (WeatherData?, Error?) -> Void){
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: OperationQueue.main)
        let endPoint = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&units=\(tempUnit)&appid=\(API.key)"
        
        guard let safeURLString = endPoint.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        
        guard let endPointURL = URL(string: safeURLString) else {
            completionHandler(nil,NetworkControllerError.InvalidURL(safeURLString))
            return
        }
        
        let dataTask = session.dataTask(with: endPointURL) { (data, response, error) in
            
            guard self.simulateError() == nil else{
                
                if let backup = self.backupController{
                    print("fallback service")
                    backup.fetchCurrentWeatherData(city: city, completionHandler: completionHandler )
                }
                else{
                    completionHandler(nil, self.simulateError())
                }
                return
            }
            
            guard error == nil else {
                completionHandler(nil, NetworkControllerError.forwarded(error!))
                return
            }
            
            guard let jsonData = data else {
                completionHandler(nil,NetworkControllerError.InvalidPayload(endPointURL))
                return
            }
            
            self.decode(jsonData: jsonData, endpointURL: endPointURL, completionHandler: completionHandler)
        }
        
        dataTask.resume()
        
        
        
    }
    
    
    private func decode(jsonData: Data, endpointURL: URL, completionHandler: @escaping (WeatherData?, NetworkControllerError?) -> Void) {
        let decoder = JSONDecoder()
        do {
            let weatherInfo = try decoder.decode(OpenMapWeatherData.self, from: jsonData)
            
            let weatherData = WeatherData(temperature: weatherInfo.main.temp, condition: (weatherInfo.weather.first?.main ?? "?"), unit: self.tempUnit)
            completionHandler(weatherData, nil)
        } catch let error {
            completionHandler(nil, NetworkControllerError.forwarded(error))
        }
    }
}



