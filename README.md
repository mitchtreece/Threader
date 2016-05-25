# Threader
Pretty GCD calls and easier code execution.

[![Version](https://img.shields.io/cocoapods/v/Threader.svg?style=flat)](http://cocoapods.org/pods/Threader)
[![License](https://img.shields.io/cocoapods/l/Threader.svg?style=flat)](http://cocoapods.org/pods/Threader)
[![Platform](https://img.shields.io/cocoapods/p/Threader.svg?style=flat)](http://cocoapods.org/pods/Threader)

## Overview
Threader makes GCD calls easy to read & write. It also provides a simple way to execute code where and when you want.

## Installation
### CocoaPods
Threader is integrated with CocoaPods!

1. Add the following to your `Podfile`:
```
use_frameworks!
pod 'Threader'
```
2. In your project directory, run `pod install`
3. Import the `Threader` module wherever you need it
4. Profit

### Manually
You can also manually add the source files to your project.

1. Clone this git repo
2. Add all the Swift files in the `Threader/` subdirectory to your project
3. Profit

## Thread
Using `Thread` you can fine-tune where and how code get executed.

```swift
Thread.Main.execute {
    /* Important main-thread code */
}
```

The above simply executes the code within the block on the main-thread. Naturally, `Thread` also provides other execution options:

- **Immediate** - executes the code block immediately on the current-thread.
- **Dispatch** - executes the code block on a given `DispatchQueue`.
- **Operation** - executes the code block on a given `NSOperationQueue`.
- **Block** - executes the code block from within a wrapper-block.
- **Main** - executes the code block on the main-thread.
- **Default** - executes the code block on the current-thread, _or_ on a global `DispatchQueue` depending on the block's current position in the thread.

Dispatching code to a given queue is as easy as:

```swift
let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
Thread.Dispatch(.Async(queue)).execute {
    /* Important background-thread code */
}
```

Hmm, better. But this still could be simpler.

## DispatchQueue
`DispatchQueue` is a small wrapper over GCD dispatch calls that helps cut down on all that non-swifty code. Like `Thread`, `DispatchQueue` shares a similar syntax. In fact, under-the-hood, `Thread` uses `DispatchQueue` for all of it's dispatch calls.

```swift
DispatchQueue.AsyncMain.execute {
    /* Important main-thread code */
}
```

Like before, the above example simply executes the code within the block on the main-thread. `DispatchQueue` also provides more execution options:

- **Async** - executes the code block asynchronously on a given `dispatch_queue_t`.
- **AsyncMain** - executes the code block asynchronously on the main-queue.
- **AsyncGlobal** - executes the code block asynchronously on the global-queue with a given `dispatch_queue_priority_t`.
- **AsyncAfter** - executes the code block asynchronously with a given delay (`NSTimeInterval`), and `dispatch_queue_t`.
- **BarrierAsync** - executes the code block asynchronously blocking on a given `dispatch_queue_t`.
- **Sync** - executes the code block synchronously on a given `dispatch_queue_t`.
- **BarrierSync** - executes the code block synchronously blocking on a given `dispatch_queue_t`.
- **Once** - executes the code block once and only once for the lifetime of an application.

In addition to executing code, `DispatchQueue` also provides convenience functions for retrieving common queue's:

```swift
public static func mainQueue() -> dispatch_queue_t {}
public static func globalQueue(priority: dispatch_queue_priority_t) -> dispatch_queue_t {}
public static func userInteractiveQueue() -> dispatch_queue_t {}
public static func userInitiatedQueue() -> dispatch_queue_t {}
public static func utilityQueue() -> dispatch_queue_t {}
public static func backgroundQueue() -> dispatch_queue_t {}
```

To grab a queue:

```swift
let mainQueue = DispatchQueue.mainQueue()
let backgroundQueue = DispatchQueue.backgroundQueue()
...
```
