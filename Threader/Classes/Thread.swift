//
//  Thread.swift
//  Threader
//
//  Created by Mitch Treece on 4/25/16.
//  Copyright © 2016 Mitch Treece. All rights reserved.
//

import Foundation

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
