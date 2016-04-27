//
//  DispatchQueue.swift
//  Threader
//
//  Created by Mitch Treece on 4/26/16.
//  Copyright © 2016 Mitch Treece. All rights reserved.
//

import Foundation

/**
 `DispatchQueue` is a wrapper around GCD that makes dispatch calls simple and readable.
 
 - Async:           runs code asynchronously on a given `dispatch_queue_t`.
 - AsyncMain:       runs code asynchronously on the main queue.
 - AsyncGlobal:     runs code asynchronously on the global queue with a given `dispatch_queue_priority_t`.
 - AsyncAfter:      runs code asynchronously with a given delay (`NSTimeInterval`), and `dispatch_queue_t`.
 - Sync:            runs code synchronously on a given `dispatch_queue_t`.
 - Once:            runs code once and only once for the lifetime of the application.
 */
public enum DispatchQueue: CustomStringConvertible, CustomDebugStringConvertible {
    
    public typealias DispatchExecutionBlock = ((Void) -> (Void))
    
    case Async(dispatch_queue_t)
    case AsyncMain
    case AsyncGlobal(dispatch_queue_priority_t)
    case AsyncAfter(NSTimeInterval, dispatch_queue_t)
    case Sync(dispatch_queue_t)
    case Once(dispatch_once_t)
    
    /**
     Runs the code block with respect to the current dispatch option.
     
     - parameter block: The code block.
     */
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
    
    /**
     Convienience function that returns the main dispatch queue.
     
     - returns: `dispatch_queue_t`. The main dispatch queue.
     */
    public static func mainQueue() -> dispatch_queue_t {
        return dispatch_get_main_queue()
    }
    
    /**
     Convienience function that returns a global dispatch queue with a given `dispatch_queue_priority_t`.
     
     - returns: `dispatch_queue_t`. A global dispatch queue.
     */
    public static func globalQueue(priority: dispatch_queue_priority_t) -> dispatch_queue_t {
        return dispatch_get_global_queue(priority, 0)
    }
    
    /**
     Convienience function that returns the global user interactive dispatch queue.
     
     - returns: `dispatch_queue_t`. The global user interactive dispatch queue.
     */
    public static func userInteractiveQueue() -> dispatch_queue_t {
        return dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.rawValue), 0)
    }
    
    /**
     Convienience function that returns the global user initiated dispatch queue.
     
     - returns: `dispatch_queue_t`. The global user initiated dispatch queue.
     */
    public static func userInitiatedQueue() -> dispatch_queue_t {
        return dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)
    }
    
    /**
     Convienience function that returns the global utility dispatch queue.
     
     - returns: `dispatch_queue_t`. The global utility dispatch queue.
     */
    public static func utilityQueue() -> dispatch_queue_t {
        return dispatch_get_global_queue(Int(QOS_CLASS_UTILITY.rawValue), 0)
    }
    
    /**
     Convienience function that returns the global background dispatch queue.
     
     - returns: `dispatch_queue_t`. The global background dispatch queue.
     */
    public static func backgroundQueue() -> dispatch_queue_t {
        return dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.rawValue), 0)
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
