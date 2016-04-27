//
//  Thread.swift
//  Threader
//
//  Created by Mitch Treece on 4/25/16.
//  Copyright © 2016 Mitch Treece. All rights reserved.
//

import Foundation

private struct ThreadDepth {
    static let key = "threader.thread.depth"
    static let max = 20
}

/**
 `Thread` provides a simple way to specify how a block of code is executed.
 
 - Immediate:      executes code immediately.
 - Main:           executes code on the main thread.
 - Dispatch:       executes code on a given `DispatchQueue`.
 - Operation:      executes code on a given `NSOperationQueue`.
 - Block:          executes code from a closure.
 - Default:        executes code on the current thread, or on a global `DispatchQueue` depending on the block of code's current position in the thread.
 */
public enum Thread {
    
    public typealias ThreadExecutionBlock = ((Void) -> (Void))
    
    case Immediate
    case Main
    case Dispatch(DispatchQueue)
    case Operation(NSOperationQueue)
    case Block((ThreadExecutionBlock) -> Void)
    case Default
    
    /**
     Runs the code block with respect to the current execution option.
     
     - parameter block: The code block.
     */
    public func execute(block: ThreadExecutionBlock) {
        
        switch self {
        case .Immediate: block()
        case .Main: DispatchQueue.AsyncMain.execute(block)
        case .Dispatch(let dispatchQueue): dispatchQueue.execute(block)
        case .Operation(let operationQueue): operationQueue.addOperationWithBlock(block)
        case .Block(let aBlock): aBlock(block)
        case .Default:
            
            let thread = NSThread.currentThread().threadDictionary
            var lastDepth: Int
            
            if let depth = thread[ThreadDepth.key] as? Int { lastDepth = depth }
            else { lastDepth = 0 }
            
            if lastDepth > ThreadDepth.max { DispatchQueue.AsyncGlobal(DISPATCH_QUEUE_PRIORITY_DEFAULT).execute(block) }
            else {
                thread[ThreadDepth.key] = lastDepth + 1
                block()
                thread[ThreadDepth.key] = lastDepth
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
        case .Block: return "Thread.Block"
        case .Default: return "Thread.Default"
        }
    }
    
    public var debugDescription: String {
        return description
    }
    
}
