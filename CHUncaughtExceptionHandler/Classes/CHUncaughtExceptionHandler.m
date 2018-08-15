//
//  CHUncaughtExceptonHandler.m
//  CarchDemo
//
//  Created by 灰谷iMac on 2018/8/14.
//  Copyright © 2018年 灰谷iMac. All rights reserved.
//

#import "CHUncaughtExceptionHandler.h"
#import "CHLogViewController.h"
#import "CHConsts.h"
#include <libkern/OSAtomic.h>
#include <execinfo.h>
#import <mach-o/dyld.h>

@import AudioToolbox;

NSString * const UncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";
NSString * const UncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";
NSString * const UncaughtExceptionHandlerAddressesKey = @"UncaughtExceptionHandlerAddressesKey";

volatile int32_t UncaughtExceptionCount = 0;
const int32_t UncaughtExceptionMaximum = 10;

static BOOL showAlertView = NO;

void HandleException(NSException *exception);
void SignalHandler(int signal);
NSString* getAppInfo(void);

@interface CHUncaughtExceptionHandler()
@property (assign, nonatomic) BOOL dismissed;
@end

@implementation CHUncaughtExceptionHandler

static CHUncaughtExceptionHandler *manager;
+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CHUncaughtExceptionHandler alloc] init];
    });
    return manager;
}
/*
 *  异常的处理方法
 *
 *  @param install   是否开启捕获异常
 *  @param showAlert 是否在发生异常时弹出alertView
 */
- (void)installUncaughtExceptionHandler:(BOOL)showAlert {

    if (showAlert) {
        [self alertView:showAlert];
    }

    NSSetUncaughtExceptionHandler(HandleException);
    signal(SIGABRT  , SignalHandler);
    signal(SIGILL   , SignalHandler);
    signal(SIGSEGV  , SignalHandler);
    signal(SIGFPE   , SignalHandler);
    signal(SIGBUS   , SignalHandler);
    signal(SIGPIPE  , SignalHandler);
    signal(SIGTRAP  , SignalHandler);
    signal(SIGHUP   , SignalHandler);
    signal(SIGINT   , SignalHandler);
    signal(SIGQUIT  , SignalHandler);

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveLog:) name:@"saveLog" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(checkLog) name:@"checkLog" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearLog) name:@"clearLog" object:nil];

}

- (void)saveLog: (NSNotification *)notification {
    NSDictionary *notify = notification.userInfo;
    NSString *logString = [notify valueForKey:@"log"];
    logString = [NSString stringWithFormat:@"\n\n--------Log Information---------\n\n%@\n\n--------End Log Information-----\n",logString ];
    [self saveCriticalApplicationDataWith:logString];
}

- (void)checkLog {
    NSString *path = logPath;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSString *logString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        CHLogViewController *vc = [[CHLogViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        vc.title = @"日志";
        vc.textView.text = logString;
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:nav animated:YES completion:nil];
    }else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"暂无日志" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:nil]];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    }
}

- (void)clearLog {
    NSString *path = logPath;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        if (error) {
            NSLog(@"删除日志失败");
        } else {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            NSLog(@"删除日志成功");
        }
    }
}

- (void)alertView:(BOOL)show {

    showAlertView = show;
}

//获取调用堆栈
+ (NSArray *)backtrace {

    //指针列表
    void* callstack[128];
    //backtrace用来获取当前线程的调用堆栈，获取的信息存放在这里的callstack中
    //128用来指定当前的buffer中可以保存多少个void*元素
    //返回值是实际获取的指针个数
    int frames = backtrace(callstack, 128);
    //backtrace_symbols将从backtrace函数获取的信息转化为一个字符串数组
    //返回一个指向字符串数组的指针
    //每个字符串包含了一个相对于callstack中对应元素的可打印信息，包括函数名、偏移地址、实际返回地址
    char **strs = backtrace_symbols(callstack, frames);

    int i;
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (i = 0; i < frames; i++) {

        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);

    return backtrace;
}

//点击退出
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (void)alertView:(UIAlertView *)anAlertView clickedButtonAtIndex:(NSInteger)anIndex {
#pragma clang diagnostic pop

    if (anIndex == 0) {

        self.dismissed = YES;
    }
}

//处理报错信息
- (void)validateAndSaveCriticalApplicationData:(NSException *)exception {

    NSString *exceptionInfo = [NSString stringWithFormat:@"\n\n--------Log Exception---------\nappInfo             :\n%@\n\nexception name      :%@\nexception reason    :%@\nexception userInfo  :%@\ncallStackSymbols    :%@\n\n--------End Log Exception-----\n", getAppInfo(),exception.name, exception.reason, exception.userInfo ? : @"no user info", [exception callStackSymbols]];

    [self saveCriticalApplicationDataWith:exceptionInfo];
}
//保存错误str
- (void)saveCriticalApplicationDataWith:(NSString *)str {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = logPath;

    if (![fileManager fileExistsAtPath:filePath]) {
        [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    }
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[str dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandle closeFile];
}

- (void)handleException:(NSException *)exception {

    [self validateAndSaveCriticalApplicationData:exception];

    if (!showAlertView) {
        return;
    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    UIAlertView *alert =
    [[UIAlertView alloc]
     initWithTitle:@"出错啦"
     message:[NSString stringWithFormat:@"你可以尝试继续操作，但是应用可能无法正常运行.\n"]
     delegate:self
     cancelButtonTitle:@"退出"
     otherButtonTitles:@"继续", nil];
    [alert show];
#pragma clang diagnostic pop

    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);

    while (!self.dismissed) {
        //点击继续
        for (NSString *mode in (__bridge NSArray *)allModes) {
            //快速切换Mode
            CFRunLoopRunInMode((CFStringRef)mode, 0.001, false);
        }
    }

    //点击退出
    CFRelease(allModes);

    NSSetUncaughtExceptionHandler(NULL);
    signal(SIGABRT  , SIG_DFL);
    signal(SIGILL   , SIG_DFL);
    signal(SIGSEGV  , SIG_DFL);
    signal(SIGFPE   , SIG_DFL);
    signal(SIGBUS   , SIG_DFL);
    signal(SIGPIPE  , SIG_DFL);
    signal(SIGTRAP  , SIG_DFL);
    signal(SIGHUP   , SIG_DFL);
    signal(SIGINT   , SIG_DFL);
    signal(SIGQUIT  , SIG_DFL);

    if ([[exception name] isEqual:UncaughtExceptionHandlerSignalExceptionName]) {

        kill(getpid(), [[[exception userInfo] objectForKey:UncaughtExceptionHandlerSignalKey] intValue]);

    } else {

        [exception raise];
    }
}
@end


void HandleException(NSException *exception) {


    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    // 如果太多不用处理
    if (exceptionCount > UncaughtExceptionMaximum) {
        return;
    }

    //获取调用堆栈
    NSArray *callStack = [exception callStackSymbols];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
    [userInfo setObject:callStack forKey:UncaughtExceptionHandlerAddressesKey];

    //在主线程中，执行制定的方法, withObject是执行方法传入的参数
    [[[CHUncaughtExceptionHandler alloc] init]
     performSelectorOnMainThread:@selector(handleException:)
     withObject:
     [NSException exceptionWithName:[exception name]
                             reason:[exception reason]
                           userInfo:userInfo]
     waitUntilDone:YES];

}

//处理signal报错
void SignalHandler(int signal) {

    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    // 如果太多不用处理
    if (exceptionCount > UncaughtExceptionMaximum) {
        return;
    }

    NSString* description = nil;
    switch (signal) {
        case SIGABRT:
            description = [NSString stringWithFormat:@"Signal SIGABRT was raised!\n"];
            break;
        case SIGILL:
            description = [NSString stringWithFormat:@"Signal SIGILL was raised!\n"];
            break;
        case SIGSEGV:
            description = [NSString stringWithFormat:@"Signal SIGSEGV was raised!\n"];
            break;
        case SIGFPE:
            description = [NSString stringWithFormat:@"Signal SIGFPE was raised!\n"];
            break;
        case SIGBUS:
            description = [NSString stringWithFormat:@"Signal SIGBUS was raised!\n"];
            break;
        case SIGPIPE:
            description = [NSString stringWithFormat:@"Signal SIGPIPE was raised!\n"];
            break;
        default:
            description = [NSString stringWithFormat:@"Signal %d was raised!",signal];
    }

    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    NSArray *callStack = [CHUncaughtExceptionHandler backtrace];
    [userInfo setObject:callStack forKey:UncaughtExceptionHandlerAddressesKey];
    [userInfo setObject:[NSNumber numberWithInt:signal] forKey:UncaughtExceptionHandlerSignalKey];

    //在主线程中，执行指定的方法, withObject是执行方法传入的参数
    [[[CHUncaughtExceptionHandler alloc] init]
     performSelectorOnMainThread:@selector(handleException:)
     withObject:
     [NSException exceptionWithName:UncaughtExceptionHandlerSignalExceptionName
                             reason: description
                           userInfo: userInfo]
     waitUntilDone:YES];
}

NSString* getAppInfo() {

    NSString *appInfo = [NSString stringWithFormat:@"App : %@ %@(%@)\nDevice : %@\nOS Version : %@ %@\n",
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"],
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"],
                         [UIDevice currentDevice].model,
                         [UIDevice currentDevice].systemName,
                         [UIDevice currentDevice].systemVersion];
    return appInfo;
}
