//
//  CHConsts.h
//  demo
//
//  Created by 灰谷iMac on 2018/8/15.
//  Copyright © 2018年 灰谷iMac. All rights reserved.
//

#ifndef CHConsts_h
#define CHConsts_h


#endif /* CHConsts_h */

@import UIKit;

#define kRatioH(h) ((h)*kWindowH/(2*667))
#define kRatioW(w) ((w)*kWindowW/(2*375))
#define kWindowW [UIScreen mainScreen].bounds.size.width
#define kWindowH [UIScreen mainScreen].bounds.size.height

#define CHHexColor(rgbValue)[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define LLColor CHHexColor(0x00a0e9)//LLHexColor(0x00a0e9)//0xda251c
#define navColor CHHexColor(0x00a0e9)//f6f6f6
#define bgColor CHHexColor(0xffffff)
#define navTextColor CHHexColor(0xffffff)
#define llDemoBundlePath [[NSBundle mainBundle] pathForResource:@"LLDemoResources" ofType:@"bundle"]
#define llDemoImage(name) [UIImage imageWithContentsOfFile:[[NSBundle bundleWithPath:llDemoBundlePath] pathForResource:name ofType:@"png"]]
#define logPath ([NSString stringWithFormat:@"%@/Documents/errorLog.text",NSHomeDirectory()])
