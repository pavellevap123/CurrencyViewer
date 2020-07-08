//
//  CurrencyManager.swift
//  CurrencyViewer
//
//  Created by Pavel on 7/8/20.
//  Copyright © 2020 Pavel. All rights reserved.
//

import Foundation

protocol CurrencyManagerDelegate {
    func didUpdateRates(_ currencyManager: CurrencyManager, _ rates: RatesModel)
    func didFailWithError(error: Error)
}

struct CurrencyManager {
    
    var delegate: CurrencyManagerDelegate?
    
    let currencyTypes = [CurrencyModel(name: "USD", symbol: "$"),
                         CurrencyModel(name: "GBP", symbol: "£"),
                         CurrencyModel(name: "RUB", symbol: "₽"),
                         CurrencyModel(name: "EUR", symbol: "€")
                        ]
    
    let baseURL = "https://api.exchangeratesapi.io/latest?base="
    
    func fetchCurrencyRate(currencyName: String) {
        let urlString = baseURL + currencyName
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        if let safeUrl = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: safeUrl) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                } else {
                    if let safeData = data {
                        if let rates = self.decodeData(safeData) {
                            self.delegate?.didUpdateRates(self, rates)
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    func decodeData(_ data: Data) -> RatesModel? {
            let decoder = JSONDecoder()
            do {
                let decodedData = try decoder.decode(RatesModel.self, from: data)
                return decodedData
            } catch {
                print(error)
            }
        return nil
    }
}
