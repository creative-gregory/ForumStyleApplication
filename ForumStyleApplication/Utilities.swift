//
//  Utilities.swift
//  InClass10
//
//  Created by Gregory Hagins II on 4/14/20.
//  Copyright © 2020 Gregory Hagins II. All rights reserved.
//

import UIKit

func initActivityMonitor(activityIndicator: UIActivityIndicatorView, view: UIView) {
    activityIndicator.center = view.center
    activityIndicator.hidesWhenStopped = true
    activityIndicator.style = UIActivityIndicatorView.Style.medium
    activityIndicator.color = .systemPurple
    activityIndicator.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
    
    view.addSubview(activityIndicator)
}

func displayAlert(title: String, message: String) -> UIAlertController {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    
    return alert
}

func getDate() -> String {
    let date = Date()
    let formatter = DateFormatter()
    
    formatter.dateFormat = "MM/dd/yyyy · HH:mm:ss.SSSS"
    formatter.timeZone = TimeZone(abbreviation: "UTC")
    
    let dateTime = formatter.string(from: date)
    
    return dateTime
}

func convertToUserTimeZone(dateStr: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yyyy · HH:mm:ss.SSSS"
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    
    guard let date = dateFormatter.date(from: dateStr) else { return String() }
    dateFormatter.timeZone = TimeZone.current
    dateFormatter.dateFormat = "MM/dd/yyyy · HH:mm"
    
    return dateFormatter.string(from: date)
    
}

func generatePostID() -> String {
    return UUID().uuidString
}

func log(message: String, errorFlag: Bool) {    
    switch errorFlag {
    case false:
        print("Info: \(getDate()) - \(message)")
    case true:
        print("Err: \(getDate()) - \(message)")
    }
}
