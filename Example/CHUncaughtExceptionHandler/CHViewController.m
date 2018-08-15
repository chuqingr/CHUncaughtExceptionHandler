//
//  CHViewController.m
//  CHUncaughtExceptionHandler
//
//  Created by 杨胜浩 on 08/15/2018.
//  Copyright (c) 2018 杨胜浩. All rights reserved.
//

#import "CHViewController.h"
#import <CHUncaughtExceptionHandler/CHUncaughtExceptionHandler.h>

@interface CHViewController ()

@end

@implementation CHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    debugLog(@"%@",@"这是一个会被记录的日志");

    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(111, 333, 111, 66)];
    [self.view addSubview:btn];
    btn.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.6];
    [btn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)click:(UIButton *) btn {
    NSString *str;
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];

    [dic setObject:str forKey:@"ddd"];
    NSLog(@"%@---%@",dic[@"ddd"],dic[@"dddddd"]);}

/// 开启摇一摇
- (void)openShakeGesture {
    [UIApplication sharedApplication].applicationSupportsShakeToEdit = YES;
    [self.view becomeFirstResponder];
}

/// 摇一摇唤出log界面
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    [NSNotificationCenter.defaultCenter postNotificationName:@"checkLog" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
