//
//  Threader.swift
//  Threader
//
//  Created by Mitch Treece on 4/25/16.
//  Copyright © 2016 Mitch Treece. All rights reserved.
//

import Foundation

/**
 `Threader` provides a simple way to specify how a block of code is executed.
 
 - immediate:           executes code immediately.
 - dispatchAsync:       executes code on a given `DispatchQueue` asynchronously.
 - dispatchAsyncMain:   executes code on the main thread.
 - dispatchAsyncGlobal  executes code on the global queue.
 - dispatchAsyncAfter   executes code on a given `DispatchQueue` after a given amount of time.
 - dispatchAsyncBarrier executes code asynchronously blocking on a given `DispatchQueue`.
 - dispatchSync:        executes code on a given `DispatchQueue` synchronously.
 - dispatchSyncBarrier  executes code synchronously blocking on a given `DispatchQueue`.
 - operation:           executes code on a given `NSOperationQueue`.
 - block:               executes code from a closure.
 - default:             executes code on the current thread, or on a global `DispatchQueue` depending on the block of code's current position in the thread.
 */
public enum Threader {
    
    private struct Depth {
        static let key = "threader.depth"
        static let max = 20
    }
    
    public typealias ThreadExecutionBlock = () -> ()
    
    case immediate
    case dispatchAsync(on: DispatchQueue)
    case dispatchAsyncMain
    case dispatchAsyncGlobal
    case dispatchAsyncAfter(time: DispatchTime, on: DispatchQueue)
    case dispatchAsyncBarrier(on: DispatchQueue)
    case dispatchSync(on: DispatchQueue)
    case dispatchSyncBarrier(on: DispatchQueue)
    case operation(on: OperationQueue)
    case block((ThreadExecutionBlock) -> Void)
    case `default`
    
    /**
     Runs the code block with respect to the current execution option.
     
     - parameter block: The code block.
     */
    public func execute(block: @escaping ThreadExecutionBlock) {
        
        switch self {
        case .immediate: block()
        case .dispatchAsync(let queue): queue.async(execute: block)
        case .dispatchAsyncMain: DispatchQueue.main.async(execute: block)
        case .dispatchAsyncGlobal: DispatchQueue.global().async(execute: block)
        case .dispatchAsyncAfter(let time, let queue): queue.asyncAfter(deadline: time, execute: block)
        case .dispatchAsyncBarrier(let queue): __dispatch_barrier_async(queue, block)
        case .dispatchSync(let queue): queue.sync(execute: block);
        case .dispatchSyncBarrier(let queue): __dispatch_barrier_sync(queue, block)
        case .operation(let queue): queue.addOperation(block)
        case .block(let aBlock): aBlock(block)
        case .default:
            
            let threadDictionary = Thread.current.threadDictionary
            var lastDepth: Int
            
            if let depth = threadDictionary[Depth.key] as? Int { lastDepth = depth }
            else { lastDepth = 0 }
            
            if lastDepth > Depth.max {
                DispatchQueue.global().async(execute: block)
            }
            else {
                threadDictionary[Depth.key] = lastDepth + 1
                block()
                threadDictionary[Depth.key] = lastDepth
            }
            
        }
        
    }
    
}

extension Threader: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        switch self {
        case .immediate: return "Threader.immediate"
        case .dispatchAsync: return "Threader.dispatchAsync"
        case .dispatchAsyncMain: return "Threader.dispatchAsyncMain"
        case .dispatchAsyncGlobal: return "Threader.dispatchAsyncGlobal"
        case .dispatchAsyncAfter: return "Threader.dispatchAsyncAfter"
        case .dispatchAsyncBarrier: return "Threader.dispatchAsyncBarrier"
        case .dispatchSync: return "Threader.dispatchSync"
        case .dispatchSyncBarrier: return "Threader.dispatchSyncBarrier"
        case .operation: return "Threader.operation"
        case .block: return "Threader.block"
        case .default: return "Threader.default"
        }
    }
    
    public var debugDescription: String {
        return description
    }
    
}
