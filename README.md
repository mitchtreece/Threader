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

## Threader
Using `Threader` you can fine-tune where and how code get executed.

```swift
Threader.DispatchAsyncMain.execute {
    /* Important main-thread code */
}
```

The above simply executes the code within the block on the main-thread. Naturally, `Threader` also provides other execution options:

- **Immediate** - executes the code block immediately on the current thread.
- **DispatchAsync** - executes the code block asynchronously on a given `DispatchQueue`.
- **DispatchAsyncMain** - executes code block asynchronously on the main thread.
- **DispatchAsyncGlobal** - executes the code block asynchronously on the global-queue.
- **DispatchAsyncAfter** - executes the code block asynchronously at a specified `DispatchTime`, on a `DispatchQueue`.
- **DispatchAsyncBarrier** - executes the code block asynchronously blocking on a given `DispatchQueue`.
- **DispatchSync** - executes the code block synchronously on a given `DispatchQueue`.
- **DispatchSyncBarrier** - executes the code block synchronously blocking on a given `DispatchQueue`.
- **Operation** - executes the code block on a given `OperationQueue`.
- **Block** - executes code from a closure.
- **Default** - executes code on the current thread, _or_ on a global `DispatchQueue` depending on the block of code's current position in the thread.

Dispatching code to a given queue is as easy as:

```swift
let queue = DispatchQueue.global()
Threader.DispatchAsync(queue).execute {
    /* Important background-thread code */
}
```

It can even be simplified further:

```swift
Threader.DispatchAsync(.global()).execute {
    /* Important background-thread code */
}
```

## DispatchQueue
In previous versions of Threader, `DispatchQueue` was a small wrapper around C-based GCD calls. However, as of __Swift 3__,
Apple decided to provide their own solution. Not surprisingly, the also named their wrapper `DispatchQueue`.
Moving forward, Threader will use Apple's native implementation of `DispatchQueue` for all GCD related calls.
