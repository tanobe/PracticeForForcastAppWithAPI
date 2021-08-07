//
//  WeatherService.swift
//  PracticeForForcastAppWithAPI
//
//  Created by 田野辺開 on 2021/06/15.
//

import CoreLocation
import Foundation

public final class WeatherService: NSObject {
    
    private let locationManager = CLLocationManager()
    private let API_KEY = "69cad86517207fdbff620c14550916a4"
    private var completionHandler: ((Weather?, LocationAuthError?) -> Void)?
    private var dataTask: URLSessionDataTask?
    
    public override init() {
        super.init()
        locationManager.delegate = self
    }
    
    public func loadWeatherData(
        _ completionHandler: @escaping((Weather?, LocationAuthError?) -> Void)
    ) {
        self.completionHandler = completionHandler
        loadDataOrRequestLocationAuth()
    }
    
    private func makeDataRequest(forCoordinates coordinates: CLLocationCoordinate2D) {
        guard let urlString =
                "https://api.openweathermap.org/data/2.5/weather?lat=\(coordinates.latitude)&lon=\(coordinates.longitude)&appid=\(API_KEY)&units=metric"
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        guard let url = URL(string: urlString) else { return }
        
        // Cancel previous task
        dataTask?.cancel()
        
        dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil, let data = data else { return }
            
            if let response = try? JSONDecoder().decode(APIResponse.self, from: data) {
                self.completionHandler?(Weather(response: response), nil)
            }
        }
        dataTask?.resume()
    }
    
    private func loadDataOrRequestLocationAuth() {
        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            completionHandler?(nil, LocationAuthError())
        default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
}

extension WeatherService: CLLocationManagerDelegate {
    public func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.first else { return }
        makeDataRequest(forCoordinates: location.coordinate)
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        loadDataOrRequestLocationAuth()
    }
    public func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        print("Something went wrong: \(error.localizedDescription)")
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

public struct LocationAuthError: Error {}


//public final class WeatherService: NSObject {
//    private let locationManager = CLLocationManager()
//    private let API_KEY = "69cad86517207fdbff620c14550916a4"
//    private var completionHandler: ((Weather) -> Void)?
//
//    public override init() {
//        super.init()
//        locationManager.delegate = self
//    }
//
//    public func loadWeatherData(_ completionHandler:  @escaping((Weather) -> Void)) {
//        self.completionHandler = completionHandler
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation()
//    }
//
//    // https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={API key}
//    private func makeDataRequest(forCoordinates coordinates: CLLocationCoordinate2D) {
//        guard let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(coordinates.latitude)&lon=\(coordinates.longitude)&appid=\(API_KEY)&units=metric".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
//        guard let url = URL(string: urlString) else { return }
//
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            guard error == nil, let data = data else { return }
//            if let response =  try? JSONDecoder().decode(APIResponse.self, from: data) {
//                self.completionHandler?(Weather(response: response))
//            }
//        }.resume()
//    }
//}
//
//extension WeatherService: CLLocationManagerDelegate {
//    public func locationManager(
//        _ manager: CLLocationManager,
//        didUpdateLocations locations: [CLLocation]
//    ) {
//        guard let location = locations.first else { return }
//        makeDataRequest(forCoordinates: location.coordinate)
//    }
//
//    public func locationManager(
//        _ manager: CLLocationManager,
//        didFailWithError error: Error) {
//        print("Something went wrong: \(error.localizedDescription)")
//    }
//}
//
//struct APIResponse: Decodable{
//    let name: String
//    let main: APIMain
//    let weather: [APIWeather]
//}
//
//struct APIMain:  Decodable{
//    let tempt: Double
//}
//
//struct APIWeather: Decodable {
//    let description: String
//    let iconName: String
//
//    enum CodingKeys: String, CodingKey {
//        case description
//        case iconName = "main"
//    }
//}
//
