//
//  NetworkController.swift
//  POP Example
//
//  Created by Sakir Saiyed on 18/04/20.
//  Copyright © 2020 Sakir Saiyed. All rights reserved.
//

import Foundation


public enum TemperatureUnit: String{
    
    case scientific = "K"
    case matric = "C"
    case imperial = "F"
    
}
public struct WeatherData{
    
    var temperature: Float
    var condition: String
    var unit: TemperatureUnit
}

public protocol NetworkController{
    
    var backupController: NetworkController? { get }
    init(backupController: NetworkController?)
    //typealias WeatherDataCompletion = (WeatherData?, Error?) -> Void
    func fetchCurrentWeatherData(city: String, completionHandler: @escaping (WeatherData?, Error?) -> Void)
    
}
extension NetworkController{
    var backupNetworkController: NetworkController? {
        return nil
    }
}

public enum NetworkControllerError : Error{
    case InvalidURL(String)
    case InvalidPayload(URL)
    case forwarded(Error)
    
}
