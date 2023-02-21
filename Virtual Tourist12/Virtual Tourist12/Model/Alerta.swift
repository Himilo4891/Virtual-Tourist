//
//  Alerta.swift
//  Virtual Tourist12
//
//  Created by abdiqani on 20/02/23.
//
import Foundation
import UIKit
class Alerta {
    
    static func showMessage(title: String, msg: String, `on` controller: UIViewController) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        controller.present(alert, animated: true, completion: nil)
    }
    
    static func presentAlert(title: String = "Error", message: String, dismiss: ((UIAlertAction) -> (Void))?) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
    }
}
