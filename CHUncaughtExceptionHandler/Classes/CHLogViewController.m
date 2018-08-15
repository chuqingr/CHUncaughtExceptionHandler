//
//  CHLogViewController.m
//  demo
//
//  Created by 灰谷iMac on 2018/8/15.
//  Copyright © 2018年 灰谷iMac. All rights reserved.
//

#import "CHLogViewController.h"
#import "CHConsts.h"

@interface CHLogViewController () <UIDocumentInteractionControllerDelegate>
@property (nonatomic, strong) UIButton *finishBtn;
@property (nonatomic, strong) UIDocumentInteractionController *documentController;
@end

@implementation CHLogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"日志";
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBarTintColor:navColor];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:navTextColor}];

    UIBarButtonItem *leftBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(clearLog)];
    UIBarButtonItem *rightBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(finishCheck)];
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(openTextWithOtherApp)];
    self.navigationItem.leftBarButtonItems = @[leftBBI];
    self.navigationItem.rightBarButtonItems = @[rightBBI,shareItem];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.textView];
}

- (void)openTextWithOtherApp {
    if (![[NSFileManager defaultManager] fileExistsAtPath:logPath]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"暂无日志" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    NSURL *url = [NSURL fileURLWithPath:logPath isDirectory:NO];
    self.documentController = [UIDocumentInteractionController interactionControllerWithURL:url];
    self.documentController.delegate = self;
    self.documentController.name = @"日志";
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.documentController presentOpenInMenuFromRect:CGRectZero
                                                    inView:self.view
                                                  animated:YES];
    });
}

-(void)documentInteractionController:(UIDocumentInteractionController *)controller
       willBeginSendingToApplication:(NSString *)application
{

}


-(void)documentInteractionController:(UIDocumentInteractionController *)controller
          didEndSendingToApplication:(NSString *)application
{
    [controller dismissMenuAnimated:YES];
}


-(void)documentInteractionControllerDidDismissOpenInMenu: (UIDocumentInteractionController *)controller
{

}


- (void)finishCheck {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)clearLog {
    self.textView.text = @"";
    [[NSNotificationCenter defaultCenter] postNotificationName:@"clearLog" object:nil];
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.frame = CGRectMake(0, 0, kWindowW, kWindowH - 64);
        _textView.editable = NO;
    }
    return _textView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
