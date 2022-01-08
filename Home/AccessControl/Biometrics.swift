//
//  Biometrics.swift
//  Home
//
//  Created by David Bohaumilitzky on 07.05.21.
//

import Foundation
import LocalAuthentication


class Biometrics{
    
    func authenticate(completion: @escaping(Bool) -> Void){
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to sign action."

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in

                DispatchQueue.main.async {
                    if success {
                        completion(true)
                        return
                    } else {
                        print(error?.localizedDescription ?? "")
                        completion(false)
                        return
                    }
                }
            }
        } else {
            completion(false)
            return
        }
    }
}

