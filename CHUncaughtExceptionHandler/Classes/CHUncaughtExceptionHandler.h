//
//  CHUncaughtExceptonHandler.h
//  CarchDemo
//
//  Created by 灰谷iMac on 2018/8/14.
//  Copyright © 2018年 灰谷iMac. All rights reserved.
//
#import <Foundation/Foundation.h>

#ifdef DEBUG

#define debugLog(fmt, ...) ((NSLog((@"%@" fmt), @"", ##__VA_ARGS__))); \
([[NSNotificationCenter defaultCenter] postNotificationName:@"saveLog" object:nil userInfo:@{@"log":[NSString stringWithFormat:fmt,##__VA_ARGS__]}]);

#else

#define debugLog(fmt, ...)

#endif

@interface CHUncaughtExceptionHandler : NSObject

/// 单例方法
+ (instancetype)defaultManager;

/*!
 *  异常的处理方法
 *
 *  @param install   是否开启捕获异常
 *  @param showAlert 是否在发生异常时弹出alertView
 */
- (void)installUncaughtExceptionHandler:(BOOL)install showAlert:(BOOL)showAlert;
@end
