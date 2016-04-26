//
//  DispatchQueue.swift
//  Threader
//
//  Created by Mitch Treece on 4/26/16.
//  Copyright © 2016 Mitch Treece. All rights reserved.
//

import Foundation

public enum DispatchQueue: CustomStringConvertible, CustomDebugStringConvertible {
    
    public typealias DispatchExecutionBlock = ((Void) -> (Void))
    
    case Async(dispatch_queue_t)
    case AsyncMain
    case AsyncGlobal(dispatch_queue_priority_t)
    case AsyncAfter(NSTimeInterval, dispatch_queue_t)
    case Sync(dispatch_queue_t)
    case Once(dispatch_once_t)
    
    public func execute(block: DispatchExecutionBlock) {
        
        switch self {
        case .Async(let queue): dispatch_async(queue, block)
        case .AsyncMain:
            
            dispatch_async(dispatch_get_main_queue(), {
                block()
            })
            
        case .AsyncGlobal(let priority): dispatch_async(dispatch_get_global_queue(priority, 0), block)
        case .AsyncAfter(let time, let queue): dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(time * Double(NSEC_PER_SEC))), queue, block)
        case .Sync(let queue): dispatch_sync(queue, block)
        case .Once(var token): dispatch_once(&token, block)
        }
        
    }
    
    public var description: String {
        switch self {
        case .Async(let queue): return "DispatchQueue.Async, Queue -> \(queue)"
        case .AsyncMain: return "DispatchQueue.AsyncMain"
        case .AsyncGlobal(let priority): return "DispatchQueue.AsyncGlobal, Priority -> \(priority)"
        case .AsyncAfter(let time, let queue): return "DispatchQueue.AsyncAfter, After -> \(time), Queue -> \(queue)"
        case .Sync(let queue): return "DispatchQueue.Sync, Queue -> \(queue)"
        case .Once(let token): return "DispatchQueue.Once, Token -> \(token)"
        }
    }
    
    public var debugDescription: String {
        return description
    }
    
}
