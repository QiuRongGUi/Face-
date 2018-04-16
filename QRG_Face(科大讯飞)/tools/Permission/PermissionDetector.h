//
//  PermissionDetector.h
//  QRG_Face(科大讯飞)
//
//  Created by 邱荣贵 on 2018/4/16.
//  Copyright © 2018年 邱久. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PermissionDetector : NSObject

/**
 *  检测麦克风权限，仅支持iOS7.0以上系统
 *
 *  @return 准许返回YES;否则返回NO
 */
+(BOOL)isMicrophonePermissionGranted;

/**
 *  检测相机权限
 *
 *  @return 准许返回YES;否则返回NO
 */
+(BOOL)isCapturePermissionGranted;

/**
 *  检测相册权限
 *
 *  @return 准许返回YES;否则返回NO
 */
+(BOOL)isAssetsLibraryPermissionGranted;


/**
 是否有相机权限

 @return <#return value description#>
 */
+ (BOOL)isCaptureDeviceServiceOpen;

/**
 否有相册权限

 @return <#return value description#>
 */
+ (BOOL)isPhotoLibraryServiceOpen;


@end

