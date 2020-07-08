//
//  ViewController.swift
//  CurrencyViewer
//
//  Created by Pavel on 7/7/20.
//  Copyright © 2020 Pavel. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var currencyLabel1: UILabel!
    @IBOutlet weak var currencyLabel2: UILabel!
    @IBOutlet weak var summLabel: UILabel!
    
    var currencyManager = CurrencyManager()
    var baseCurrency: String?
    var secondCurrency: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.delegate = self
        textField.delegate = self
        currencyManager.delegate = self
        
        self.hideKeyboardWhenTappedAround()
        
        if let firstCurrency = currencyManager.currencyTypes.first {
            currencyLabel1.text = firstCurrency.symbol
            currencyLabel2.text = firstCurrency.symbol
            baseCurrency = firstCurrency.name
            secondCurrency = firstCurrency.name
        } else {
            fatalError("No data provided for currencies")
        }
    }
    
    @IBAction func showResultTapped(_ sender: UIButton) {
        if textField.text?.count == 0 {
            self.showErrorAlert()
        } else {
            currencyManager.fetchCurrencyRate(currencyName: baseCurrency!)
        }
    }
    @IBAction func shareButtonTapped(_ sender: UIBarButtonItem) {
        let activityItem = "Text you want"
        let activityViewController = UIActivityViewController(activityItems: [activityItem], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func showErrorAlert() {
        let alert = UIAlertController(title: nil, message: "Please, enter currecy amount", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(action)
        self.present(alert, animated: true)
    }
}

extension MainViewController: CurrencyManagerDelegate {
    
    func didUpdateRates(_ currencyManager: CurrencyManager, _ rates: RatesModel) {
        DispatchQueue.main.async {
            guard let amountOfCurrency = Double(self.textField.text!) else { return }
            switch self.secondCurrency! {
            case "USD":
                self.summLabel.text = String(format: "%.2f", rates.rates.USD * amountOfCurrency)
            case "GBP":
                self.summLabel.text = String(format: "%.2f", rates.rates.GBP * amountOfCurrency)
            case "RUB":
                self.summLabel.text = String(format: "%.2f", rates.rates.RUB * amountOfCurrency)
            case "EUR":
                // Bug with API
                if rates.rates.EUR == nil {
                    self.summLabel.text = String(format: "%.2f", amountOfCurrency)
                } else {
                    self.summLabel.text = String(format: "%.2f", rates.rates.EUR! * amountOfCurrency)
                }
            default:
                print("There is no any currency with procided name.")
            }
        }
    }
    
    func didFailWithError(error: Error) {
        print("An error occured during fetcing data from API \(String(describing: error))")
    }
    
    
}

extension MainViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencyManager.currencyTypes.count
    }
}

extension MainViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            currencyLabel1.text = currencyManager.currencyTypes[row].symbol
            baseCurrency = currencyManager.currencyTypes[row].name
        } else {
            currencyLabel2.text = currencyManager.currencyTypes[row].symbol
            secondCurrency = currencyManager.currencyTypes[row].name
        }
        if textField.text?.count == 0 {
            self.showErrorAlert()
            summLabel.text = ""
        } else {
            currencyManager.fetchCurrencyRate(currencyName: baseCurrency!)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencyManager.currencyTypes[row].name
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension MainViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
         guard let text = textField.text else { return true }
         let newLength = text.count + string.count - range.length
         return newLength <= 10
    }
}

