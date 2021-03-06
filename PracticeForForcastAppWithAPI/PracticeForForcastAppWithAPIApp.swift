//
//  PracticeForForcastAppWithAPIApp.swift
//  PracticeForForcastAppWithAPI
//
//  Created by ็ฐ้่พบ้ on 2021/06/15.
//

import SwiftUI

@main
struct PracticeForForcastAppWithAPIApp: App {
    var body: some Scene {
        WindowGroup {
            let weatherService = WeatherService()
            let viewModel = WeatherViewModel(weatherService: weatherService)
            WeatherView(viewModel: viewModel)
        }
    }
}
