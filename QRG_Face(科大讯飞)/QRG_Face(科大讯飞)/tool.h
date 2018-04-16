
//
//  tool.h
//  QRG_Face(科大讯飞)
//
//  Created by 邱荣贵 on 2018/4/15.
//  Copyright © 2018年 邱久. All rights reserved.
//

#ifndef tool_h
#define tool_h


#define Margin  5
#define Padding 10
#define iOS7TopMargin 64 //导航栏44，状态栏20
#define IOS7_OR_LATER   ( [[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending )
#define ButtonHeight 44
#define NavigationBarHeight 44


#define USER_APPID           @"5ad23e75"




#ifdef __IPHONE_6_0
# define IFLY_ALIGN_CENTER NSTextAlignmentCenter
#else
# define IFLY_ALIGN_CENTER UITextAlignmentCenter
#endif

#ifdef __IPHONE_6_0
# define IFLY_ALIGN_LEFT NSTextAlignmentLeft
#else
# define IFLY_ALIGN_LEFT UITextAlignmentLeft
#endif


#endif /* tool_h */
