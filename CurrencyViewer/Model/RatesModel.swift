//
//  ResponseModel.swift
//  CurrencyViewer
//
//  Created by Pavel on 7/7/20.
//  Copyright © 2020 Pavel. All rights reserved.
//

import Foundation

struct RatesModel: Codable {
    let rates: Rates
}

struct Rates: Codable {
    let GBP: Double
    let RUB: Double
    let USD: Double
    let EUR: Double?
}
