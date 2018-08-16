# CHUncaughtExceptionHandler

[![CI Status](https://img.shields.io/travis/杨胜浩/CHUncaughtExceptionHandler.svg?style=flat)](https://travis-ci.org/杨胜浩/CHUncaughtExceptionHandler)
[![Version](https://img.shields.io/cocoapods/v/CHUncaughtExceptionHandler.svg?style=flat)](https://cocoapods.org/pods/CHUncaughtExceptionHandler)
[![License](https://img.shields.io/cocoapods/l/CHUncaughtExceptionHandler.svg?style=flat)](https://cocoapods.org/pods/CHUncaughtExceptionHandler)
[![Platform](https://img.shields.io/cocoapods/p/CHUncaughtExceptionHandler.svg?style=flat)](https://cocoapods.org/pods/CHUncaughtExceptionHandler)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

CHUncaughtExceptionHandler is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'CHUncaughtExceptionHandler'
```

## Use
### OC

``` Object-C
#import <CHUncaughtExceptionHandler/CHUncaughtExceptionHandler.h>

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[CHUncaughtExceptionHandler defaultManager] installUncaughtExceptionHandler:YES];
    return YES;
}

/// log记录
debugLog(@"%@",@"这是一个会被记录的日志");
```

### Swift
``` swift
CHUncaughtExceptionHandler.defaultManager().installUncaughtExceptionHandler(true)

func debugLog(_ items: Any) {
    debugPrint(items)
    #if DEBUG
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "saveLog"), object: nil, userInfo: ["log":items])
    #endif
}
因swift无法直接调用OC的宏定义，所以自定义一个方法，实现一样的log记录功能

```
> 如出现崩溃，会出现拦截，进行提示，信号的崩溃无法拦截。
崩溃的信息会被记录在文件中，可通过
[NSNotificationCenter.defaultCenter postNotificationName:@"checkLog" object:nil];
唤出日志界面

## Author

杨胜浩, chuqingr@icloud.com

## License

CHUncaughtExceptionHandler is available under the MIT license. See the LICENSE file for more info.
