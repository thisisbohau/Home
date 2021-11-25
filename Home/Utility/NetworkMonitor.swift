//
//  NetworkMonitor.swift
//  recipy
//
//  Created by David Bohaumilitzky on 25.02.21.
//

import Foundation
import Network

public enum ConnectionType {
    case wifi
    case ethernet
    case cellular
    case unknown
}

class NetworkStatus{
    static public let shared = NetworkStatus()
    private var monitor: NWPathMonitor
    private var queue = DispatchQueue.global()
    var isOn: Bool = true
    var connType: ConnectionType = .wifi
    var isConnected: Bool = false
//    var listener: () -> Void

    private init() {
        self.monitor = NWPathMonitor()
        self.queue = DispatchQueue.global(qos: .background)
        self.monitor.start(queue: queue)
//        self.listener = self.listener
    }

    func start() {
        self.monitor.pathUpdateHandler = { path in
            self.isOn = path.status == .satisfied
            self.connType = self.checkConnectionTypeForPath(path)
        }
    }

    func stop() {
        self.monitor.cancel()
    }

    func checkConnectionTypeForPath(_ path: NWPath) -> ConnectionType {
        DispatchQueue.main.async {
            if path.status == .unsatisfied{
                NetworkStatus.shared.isConnected = true
            }else{
                NetworkStatus.shared.isConnected = false
            }
        }
        
        if path.usesInterfaceType(.wifi) {
            return .wifi
        } else if path.usesInterfaceType(.wiredEthernet) {
            return .ethernet
        } else if path.usesInterfaceType(.cellular) {
            return .cellular
        }
        return .unknown
    }
}
