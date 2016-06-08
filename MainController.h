//
//  MainController.h
//  动享
//
//  Created by 唐余威 on 15/7/28.
//  Copyright (c) 2015年 唐余威. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AwesomeMenu.h"
@interface MainController : UITabBarController<AwesomeMenuDelegate>

@property(nonatomic,strong)AwesomeMenu *menu;
@property(nonatomic,strong)UIView *backview;
@property(nonatomic,assign)BOOL isPay;
@property(nonatomic,strong)NSMutableArray *imgArray;
@property(nonatomic,strong)NSMutableArray *labelArray;
@end


