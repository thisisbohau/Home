//
//  DishwasherKit.swift
//  Home
//
//  Created by David Bohaumilitzky on 15.01.22.
//

import Foundation

enum DishwasherOperationState{
    case Running
    case Finished
    case Error
    case Waiting
    case Off
    case Ready
    case On
    case StartLater
    case ActionRequired
    
}

class DishwasherKit{
    
    func getOperationState(status: String) -> DishwasherOperationState{
        switch status{
        case "BSH.Common.EnumType.OperationState.Inactive":
            return .Waiting
        case "BSH.Common.EnumType.OperationState.Ready":
            return .Ready
        case "BSH.Common.EnumType.OperationState.DelayedStart":
            return .StartLater
        case "BSH.Common.EnumType.OperationState.Run":
            return .Running
        case "BSH.Common.EnumType.OperationState.ActionRequired":
            return .ActionRequired
        case "BSH.Common.EnumType.OperationState.Finished":
            return .Finished
        case "BSH.Common.EnumType.OperationState.Error":
            return .Error
        default:
            return .Error
        }
    }
    
    func getOperationStateVerbos(status: DishwasherOperationState) -> String{
        switch status {
        case .Running:
            return "Running"
        case .Finished:
            return "Program Finished"
        case .Error:
            return "Error"
        case .Waiting:
            return "Waiting"
        case .Off:
            return "Off"
        case .Ready:
            return "Ready"
        case .On:
            return "On"
        case .StartLater:
            return "Delayed Start"
        case .ActionRequired:
            return "Action Required"
        }
    }
    
    func selectProgram(program: DishwasherProgram){
        Task{
            var queries = [URLQueryItem]()
            queries.append(URLQueryItem(name: "id", value: program.id.description))
            queries.append(URLQueryItem(name: "action", value: "selectProgram"))
            let _ = try? await RequestManager().makeActionRequest(requestDirectory: ActionDirectories.dishwasher, queries: queries)
        }
    }
    
    func selectOption(option: DishwasherOption, newState: Bool){
        Task{
            var queries = [URLQueryItem]()
            queries.append(URLQueryItem(name: "id", value: option.id.description))
            queries.append(URLQueryItem(name: "action", value: "selectOption"))
            queries.append(URLQueryItem(name: "newState", value: newState.description))
            let _ = try? await RequestManager().makeActionRequest(requestDirectory: ActionDirectories.dishwasher, queries: queries)
        }
    }
    
    func togglePower(){
        Task{
        var queries = [URLQueryItem]()
        queries.append(URLQueryItem(name: "action", value: "power"))
        let _ = try? await RequestManager().makeActionRequest(requestDirectory: ActionDirectories.dishwasher, queries: queries)
        }
    }
    
    func startProgram(){
        Task{
        var queries = [URLQueryItem]()
        queries.append(URLQueryItem(name: "action", value: "start"))
        let _ = try? await RequestManager().makeActionRequest(requestDirectory: ActionDirectories.dishwasher, queries: queries)
        }
    }
    func stopProgram(){
        Task{
        var queries = [URLQueryItem]()
        queries.append(URLQueryItem(name: "action", value: "stop"))
        let _ = try? await RequestManager().makeActionRequest(requestDirectory: ActionDirectories.dishwasher, queries: queries)
        }
    }
}
