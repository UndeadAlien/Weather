//
//  Weather.swift
//  Weather
//
//  Created by Connor Hutchinson on 8/29/21.
//

import Foundation
import CoreLocation

public final class WeatherService: NSObject {
    
    private let locationManager = CLLocationManager()
    private let API_KEY = "fb88d5d77462f31b1375aa4930eae937"
    private var completionHandler: ((Weather) -> Void)?
    
    public func loadWeatherData( _ completionHandler: @escaping((Weather) -> Void)) {
        self.completionHandler = completionHandler
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // api.openweathermap.org/data/2.5/find?lat=55.5&lon=37.5&cnt=10&appid={API key}
    private func makeDataRequest(forCoordinates coordinates: CLLocationCoordinate2D) {
        guard let urlString = "api.openweathermap.org/data/2.5/find?lat=\(coordinates.latitude)&lon=\(coordinates.longitude)&appid=\(API_KEY)&units=metric".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil, let data = data else { return }
            
            if let response = try? JSONDecoder().decode(APIResponse.self, from:data) {
                self.completionHandler?(Weather())
            }
        }
    }
}

struct APIResponse: Decodable {
    let name: String
    let main: APIMain
    let weather: [APIWeather]
}

struct APIMain: Decodable {
    let temp: Double
}

struct APIWeather: Decodable {
    let description: String
    let iconName: String
    
    enum CodingKeys: String, CodingKey {
        case description
        case iconName = "main"
    }
}
