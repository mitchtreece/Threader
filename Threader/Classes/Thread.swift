//
//  Thread.swift
//  Threader
//
//  Created by Mitch Treece on 4/25/16.
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

public enum Thread {
    
    public typealias ThreadExecutionBlock = ((Void) -> (Void))
    
    case Immediate
    case Main
    case Dispatch(DispatchQueue)
    case Operation(NSOperationQueue)
    case Closure((ThreadExecutionBlock) -> Void)
    case Default
    
    public func execute(block: ThreadExecutionBlock) {
        
        switch self {
        case .Immediate: block()
        case .Main: DispatchQueue.AsyncMain.execute(block)
        case .Dispatch(let dispatchQueue): dispatchQueue.execute(block)
        case .Operation(let operationQueue): operationQueue.addOperationWithBlock(block)
        case .Closure(let aClosure): aClosure(block)
        case .Default:
            
            struct Depth {
                static let key = "thread.depth"
                static let max = 20
            }
            
            let thread = NSThread.currentThread().threadDictionary
            
            var lastDepth: Int
            if let depth = thread[Depth.key] as? Int { lastDepth = depth }
            else { lastDepth = 0 }
            
            if lastDepth > Depth.max {
                DispatchQueue.AsyncGlobal(DISPATCH_QUEUE_PRIORITY_DEFAULT).execute(block)
            }
            else {
                thread[Depth.key] = lastDepth + 1
                block()
                thread[Depth.key] = lastDepth
            }
            
        }
        
    }
    
}

extension Thread: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        switch self {
        case .Immediate: return "Thread.Immediate"
        case .Main: return "Thread.Main"
        case .Dispatch: return "Thread.Dispatch"
        case .Operation: return "Thread.Operation"
        case .Closure: return "Thread.Closure"
        case .Default: return "Thread.Default"
        }
    }
    
    public var debugDescription: String {
        return description
    }
    
}