//
//  AppDelegate.h
//  动享
//
//  Created by 唐余威 on 15/7/28.
//  Copyright (c) 2015年 唐余威. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "WXApi.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate,WXApiDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)handlePublishPictureActionWithPublishPictureArray:(NSArray *)publishPictureArray andWord:(NSString *)word andNightShopID:(NSString *)nightShopId;

@end

