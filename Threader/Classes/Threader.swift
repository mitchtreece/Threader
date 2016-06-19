//
//  Threader.swift
//  Threader
//
//  Created by Mitch Treece on 4/25/16.
//  Copyright © 2016 Mitch Treece. All rights reserved.
//

import Foundation

private struct ThreadDepth {
    static let key = "threader.threadDepth"
    static let max = 20
}

/**
 `Threader` provides a simple way to specify how a block of code is executed.
 
 - Immediate:           executes code immediately.
 - DispatchAsync:       executes code on a given `DispatchQueue` asynchronously.
 - DispatchAsyncMain:   executes code on the main thread.
 - DispatchAsyncGlobal  executes code on the global queue.
 - DispatchAsyncAfter   executes code on a given `DispatchQueue` after a given amount of time.
 - DispatchAsyncBarrier executes code asynchronously blocking on a given `DispatchQueue`.
 - DispatchSync:        executes code on a given `DispatchQueue` synchronously.
 - DispatchSyncBarrier  executes code synchronously blocking on a given `DispatchQueue`.
 - Operation:           executes code on a given `NSOperationQueue`.
 - Block:               executes code from a closure.
 - Default:             executes code on the current thread, or on a global `DispatchQueue` depending on the block of code's current position in the thread.
 */
public enum Threader {
    
    public typealias ThreadExecutionBlock = () -> ()
    
    case Immediate
    
    case DispatchAsync(DispatchQueue)
    case DispatchAsyncMain
    case DispatchAsyncGlobal
    case DispatchAsyncAfter(DispatchTime, DispatchQueue)
    case DispatchAsyncBarrier(DispatchQueue)
    case DispatchSync(DispatchQueue)
    case DispatchSyncBarrier(DispatchQueue)
    
    case Operation(OperationQueue)
    case Block((ThreadExecutionBlock) -> Void)
    case Default
    
    /**
     Runs the code block with respect to the current execution option.
     
     - parameter block: The code block.
     */
    public func execute(block: ThreadExecutionBlock) {
        
        switch self {
        case .Immediate: block()
            
        case .DispatchAsync(let dispatchQueue): dispatchQueue.async(execute: block)
        case .DispatchAsyncMain: DispatchQueue.main.async(execute: block)
        case .DispatchAsyncGlobal: DispatchQueue.global().async(execute: block)
        case .DispatchAsyncAfter(let time, let dispatchQueue): dispatchQueue.after(when: time, execute: block)
        case .DispatchAsyncBarrier(let dispatchQueue): __dispatch_barrier_async(dispatchQueue, block)
        case .DispatchSync(let dispatchQueue): dispatchQueue.sync(execute: block);
        case .DispatchSyncBarrier(let dispatchQueue): __dispatch_barrier_sync(dispatchQueue, block)
            
        case .Operation(let operationQueue): operationQueue.addOperation(block)
        case .Block(let aBlock): aBlock(block)
        case .Default:
            
            let thread = Thread.current().threadDictionary
            var lastDepth: Int
            
            if let depth = thread[ThreadDepth.key] as? Int { lastDepth = depth }
            else { lastDepth = 0 }
            
            if lastDepth > ThreadDepth.max { DispatchQueue.global().async(execute: block) }
            else {
                thread[ThreadDepth.key] = lastDepth + 1
                block()
                thread[ThreadDepth.key] = lastDepth
            }
            
        }
        
    }
    
}

extension Threader: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        switch self {
        case .Immediate: return "Threader.Immediate"
        case .DispatchAsync: return "Threader.DispatchAsync"
        case .DispatchAsyncMain: return "Threader.DispatchAsyncMain"
        case .DispatchAsyncGlobal: return "Threader.DispatchAsyncGlobal"
        case .DispatchAsyncAfter: return "Threader.DispatchAsyncAfter"
        case .DispatchAsyncBarrier: return "Threader.DispatchAsyncBarrier"
        case .DispatchSync: return "Threader.DispatchSync"
        case .DispatchSyncBarrier: return "Threader.DispatchSyncBarrier"
        case .Operation: return "Threader.Operation"
        case .Block: return "Threader.Block"
        case .Default: return "Threader.Default"
        }
    }
    
    public var debugDescription: String {
        return description
    }
    
}
