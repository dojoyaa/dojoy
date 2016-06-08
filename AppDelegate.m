//
//  AppDelegate.m
//  动享
//
//  Created by 唐余威 on 15/7/28.
//  Copyright (c) 2015年 唐余威. All rights reserved.
//

#import "AppDelegate.h"
#import "MainController.h"
#import "LeftViewController.h"
#import "TQLocationConverter.h"
#import <AlipaySDK/AlipaySDK.h>
#import "GuidePageController.h"
#import "UMessage.h"
#import "UMSocial.h"
#import "SPUtil.h"
#import "UMSocialWechatHandler.h"
#import "MessageListController.h"
#import "MessageModel.h"
#import "MyOrderController.h"
#import "MyCouponsController.h"
#import "MyFightingController.h"
#import "UMSocialQQHandler.h"
#import "HomeH5Controller.h"
//APP端签名相关头文件
#import "payRequsestHandler.h"
#import "SPKitExample.h"
#import <MobClick.h>
#import "FSOSSRequest.h"
#import "HomeTwoViewController.h"
//服务端签名只需要用到下面一个头文件
//#import "ApiXml.h"
#import <QuartzCore/QuartzCore.h>
#define UMSYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define _IPHONE80_ 80000
@interface AppDelegate ()
/******上传的图片存储********/

@property (nonatomic, strong) NSMutableArray *publishPictureUrlStringArray;
@property (nonatomic, strong) NSArray *publishPictureArray;
@property (nonatomic, copy) NSString *publishWord;

@end

@implementation AppDelegate
{
    //定位属性
    CLLocationManager *_locatioManager;
    CLLocation *_location;
    NSString *ConversationId;
    NSDictionary *_h5Dic;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {


    [[SPKitExample sharedInstance] callThisInDidFinishLaunching];
    //set AppKey and AppSecret
    [UMessage startWithAppkey:@"557000fb67e58e3d7b002b2a" launchOptions:launchOptions];
    [MobClick startWithAppkey:@"557000fb67e58e3d7b002b2a" reportPolicy:BATCH   channelId:@""];
    
    
    
    /// 需要区分iOS SDK版本和iOS版本。
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge|UIUserNotificationTypeAlert|UIUserNotificationTypeSound) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        
    } else
#endif
    {
        /// 去除warning
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
#pragma clang diagnostic pop
    }
    
    

    
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
    if(UMSYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        //register remoteNotification types （iOS 8.0及其以上版本）
        UIMutableUserNotificationAction *action1 = [[UIMutableUserNotificationAction alloc] init];
        action1.identifier = @"action1_identifier";
        action1.title=@"Accept";
        action1.activationMode = UIUserNotificationActivationModeForeground;//当点击的时候启动程序
        
        UIMutableUserNotificationAction *action2 = [[UIMutableUserNotificationAction alloc] init];  //第二按钮
        action2.identifier = @"action2_identifier";
        action2.title=@"Reject";
        action2.activationMode = UIUserNotificationActivationModeBackground;//当点击的时候不启动程序，在后台处理
        action2.authenticationRequired = YES;//需要解锁才能处理，如果action.activationMode = UIUserNotificationActivationModeForeground;则这个属性被忽略；
        action2.destructive = YES;
        
        UIMutableUserNotificationCategory *categorys = [[UIMutableUserNotificationCategory alloc] init];
        categorys.identifier = @"category1";//这组动作的唯一标示
        [categorys setActions:@[action1,action2] forContext:(UIUserNotificationActionContextDefault)];
        
        UIUserNotificationSettings *userSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert
                                                                                     categories:[NSSet setWithObject:categorys]];
        [UMessage registerRemoteNotificationAndUserNotificationSettings:userSettings];
        
    } else{
        //register remoteNotification types (iOS 8.0以下)
        [UMessage registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge
         |UIRemoteNotificationTypeSound
         |UIRemoteNotificationTypeAlert];
    }
#else
    
    //register remoteNotification types (iOS 8.0以下)
    [UMessage registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge
     |UIRemoteNotificationTypeSound
     |UIRemoteNotificationTypeAlert];
    
#endif
    //for log
    [UMessage setLogEnabled:YES];
    
    
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
    [self.window makeKeyAndVisible];
    
//    LeftViewController *leftCol = [[LeftViewController alloc] init];
//    MMDrawerController *drawerCol = [[MMDrawerController alloc] initWithCenterViewController:col leftDrawerViewController:leftCol];
//    [drawerCol setMaximumLeftDrawerWidth:100.0];
//    [drawerCol setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
//    [drawerCol setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    //
    
    
    
    NSDictionary *dictory = @{@"longitude":@"",@"latitude":@""};
    [[NSUserDefaults standardUserDefaults] setObject:dictory forKey:KCoordinates];
//    NSArray *array = [NSArray array];
//    [[NSUserDefaults standardUserDefaults] setObject:array forKey:kCityList];
    NSDictionary *user = [[NSUserDefaults standardUserDefaults] objectForKey:kUserBaseInfo];
    if (user == nil) {
        NSDictionary *dic = @{@"token":@"",@"logintype":@"",@"tel":@""};
        [[NSUserDefaults standardUserDefaults] setObject:dic forKey:kUserBaseInfo];
        NSDictionary *UmDic = @{@"UmID":@"",@"Umpwd":@""};
        [[NSUserDefaults standardUserDefaults] setObject:UmDic forKey:KUmAccount];
    }
    NSString *cityID =[[NSUserDefaults standardUserDefaults] objectForKey:kCityID];
    if (cityID == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:@"179" forKey:kCityID];
    }
    //定位
    //iOS8 之后定位：
    //1.[_locatioManager requestWhenInUseAuthorization]; //请求授权
    //2.在Info.plist文件还要加上NSLocationWhenInUseUsageDescription这个key,Value可以为空
    if (_locatioManager == nil) {
        _locatioManager = [[CLLocationManager alloc] init];
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
            [_locatioManager requestWhenInUseAuthorization];
        }
        
        //设置定位的精准度
        [_locatioManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
        _locatioManager.distanceFilter = 10;
        _locatioManager.delegate = self;
    }
    [_locatioManager startUpdatingLocation];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    

    if([userDefaults objectForKey:@"FirstLoad"] == nil)
    {
        [userDefaults setBool:NO forKey:@"FirstLoad"];
        GuidePageController *PilotCol = [[GuidePageController alloc] init];
        self.window.rootViewController = PilotCol;
    }else{
        MainController *col = [[MainController alloc] init];

        self.window.rootViewController = col;
    }
    
    
    //向微信注册
    [WXApi registerApp:APP_ID withDescription:@"动享网"];
//    [NSThread sleepForTimeInterval:10.0];
    //友盟分享
    [UMSocialData setAppKey:@"557000fb67e58e3d7b002b2a"];
    [UMSocialWechatHandler setWXAppId:@"wxdde9ae448e33ed4c" appSecret:@"a241ba2926c491bf76a00f4fec6bf395" url:@"http://www.umeng.com/social"];
    [UMSocialQQHandler setQQWithAppId:@"1104628401" appKey:@"dfHcv6zQMuvSlSgO" url:@"http://www.umeng.com/social"];

    [self exampleHandleAPNSWithLaunchOptions:launchOptions];
    
    return YES;
}


// 每隔多少米定一次位

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    
    NSLog(@"%@",error);
    
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    [manager stopUpdatingLocation];
    _location = [locations lastObject];
    CLLocationCoordinate2D coordinate = _location.coordinate;
//    NSLog(@"纬度：%f,经度：%f",coordinate.latitude,coordinate.longitude);
    coordinate =  [TQLocationConverter transformFromWGSToGCJ:coordinate];
    coordinate = [TQLocationConverter transformFromGCJToBaidu:coordinate];
//    NSLog(@"纬度2：%f,经度2：%f",coordinate.latitude,coordinate.longitude);
    NSString *x = [NSString stringWithFormat:@"%f",coordinate.longitude];
    NSString *y = [NSString stringWithFormat:@"%f",coordinate.latitude];
    NSDictionary *dictory = @{@"longitude":x,@"latitude":y};
    [[NSUserDefaults standardUserDefaults] setObject:dictory forKey:KCoordinates];
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:_location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *place = [placemarks lastObject];
      
        [[NSUserDefaults standardUserDefaults] setObject:place.locality forKey:KLocatingcity];
    }];

    
    
}
// 应用程序将进入后台
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}
// 应用程序已经进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}
// 应用程序将进入前台
- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}
// 应用程序已经进入前台
- (void)applicationDidBecomeActive:(UIApplication *)application {
    
   
    [self performSelector:@selector(requestFindNewMessages) withObject:nil afterDelay:1];
    
}


- (void)requestFindNewMessages
{
    NSDictionary *user = [[NSUserDefaults standardUserDefaults] objectForKey:kUserBaseInfo];
    NSDictionary *dic = @{@"tel":user[@"tel"],@"token":user[@"token"],@"logintype":user[@"logintype"]};
    NSMutableDictionary *dic2 = [NSMutableDictionary dictionaryWithDictionary:dic];
    NSString *param = [NSString dataWithParams:dic2];
    [MyDataRequest requestURL:@"2112" params:@{@"data":param} completion:^(id result, id operation) {
//        NSLog(@"+++++++++++++++++%@",result);
        NSString *status = [NSString stringWithFormat:@"%@",result[@"status"]];
        if ([status isEqualToString:@"200"]) {
            
            NSDictionary *infobean = result[@"infobean"];
            NSDictionary *usernotice = infobean[@"usernotice"];
            NSString *newmsgcnt = [NSString stringForId:usernotice[@"newmsgcnt"]];
            NSString *newpreferentialcnt = [NSString stringForId:usernotice[@"newpreferentialcnt"]];
            NSString *newclubcardcnt = [NSString stringForId:usernotice[@"newclubcardcnt"]];
            if ([newmsgcnt integerValue] > 0) {
                NSNotification *notification =[NSNotification notificationWithName:kNewMessage object:nil userInfo:nil];
                //通过通知中心发送通知
                [[NSNotificationCenter defaultCenter] postNotification:notification];
                
            }
            if ([newpreferentialcnt integerValue] >0) {
          
                
            }
            if ([newclubcardcnt integerValue] >0) {
   
                
            }
            
        }

    }];

    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    //跳转支付宝钱包进行支付，处理支付结果
    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
//        NSLog(@"result = %@",resultDic);
        
        
    }];
    [UMSocialSnsService handleOpenURL:url];
    [WXApi handleOpenURL:url delegate:self];
    return YES;
}
-(void) onResp:(BaseResp*)resp
{
    NSString *strMsg = [NSString stringWithFormat:@"errcode:%d", resp.errCode];
    NSString *strTitle;
    
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        strTitle = [NSString stringWithFormat:@"发送媒体消息结果"];
    }
    if([resp isKindOfClass:[PayResp class]]){
        //支付返回结果，实际支付结果需要去微信服务器端查询
        strTitle = [NSString stringWithFormat:@"支付结果"];
        
        switch (resp.errCode) {
            case WXSuccess:
                strMsg = @"支付成功";
                NSLog(@"支付成功－PaySuccess，retcode = %d", resp.errCode);
                break;
                
            default:
                strMsg = [NSString stringWithFormat:@"支付结果：失败！"];
                NSLog(@"错误，retcode = %d, retstr = %@", resp.errCode,resp.errStr);
                break;
        }
    }
    if([resp isKindOfClass:[PayResp class]])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        if ([strMsg isEqualToString:@"支付成功"]) {
            alert.tag = 277;
        }else
        {
            alert.tag = 278;
        }
        [alert show];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [UMessage registerDeviceToken:deviceToken];
    [self exampleSetDeviceToken:deviceToken];
//    NSLog(@"%@",[[[[deviceToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""]
//                  stringByReplacingOccurrencesOfString: @">" withString: @""]
//                 stringByReplacingOccurrencesOfString: @" " withString: @""]);
    [[NSUserDefaults standardUserDefaults] setObject: [[[[deviceToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                                       stringByReplacingOccurrencesOfString: @">" withString: @""]
                                                       stringByReplacingOccurrencesOfString: @" " withString: @""]forKey:kDeviceToken];
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    //关闭友盟对话框
    [UMessage setAutoAlert:NO];
    [UMessage didReceiveRemoteNotification:userInfo];
    NSString *custom = userInfo[@"custom"];
//    NSDictionary *dic = userInfo[@"aps"];
//    NSLog(@"%@",dic[@"alert"]);
    custom = [custom stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
    NSData *data = [custom dataUsingEncoding:NSUTF8StringEncoding];
     NSDictionary *inDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    NSString *targettype = [NSString stringWithFormat:@"%@",inDic[@"targettype"]];
    //targettype;// 处理类型 0：打开消息详请 1：用户订单列表 2：用户优惠券列表 3：用户约战列表  4 我的会员卡 5 分享得好礼
    if([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
    {
       
        if ([targettype isEqualToString:@"5"]) {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@",inDic[@"messagename"]]
                                                             message:[NSString stringWithFormat:@"%@",inDic[@"content"]]
                                                            delegate:self
                                                   cancelButtonTitle:@"确定"
                                                   otherButtonTitles:@"取消",nil];
            [alert show];
            alert.tag= 211;
            _h5Dic = inDic[@"param"];
            
        }else
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@",inDic[@"messagename"]]
                                                             message:[NSString stringWithFormat:@"%@",inDic[@"content"]]
                                                            delegate:self
                                                   cancelButtonTitle:@"确定"
                                                   otherButtonTitles:nil];
            [alert show];
        }
        
        [self performSelector:@selector(requestFindNewMessages) withObject:nil afterDelay:1];
        return;
    }
//    MMDrawerController *drawerCol = (MMDrawerController *)self.window.rootViewController;
//    MainController *mainCol = (MainController *)drawerCol.centerViewController;
    
//    UINavigationController *nav  = (UINavigationController *)mainCol.selectedViewController;
//    NSArray *array = nav.viewControllers;
//    UIViewController *pushCol =  array[array.count-1];
    if ([targettype isEqualToString:@"0"]) {
        MessageListController *col = [[MessageListController alloc] init];
//        MessageModel *model = [[MessageModel alloc] init];
//        NSString *messagetype = [NSString stringWithFormat:@"%@",inDic[@"messagetype"]];
//        model.messagetype = messagetype;
//        col.num = [messagetype integerValue];
//        col.model = model;
        col.hidesBottomBarWhenPushed = YES;
        col.isHidden = YES ;
//        [pushCol.navigationController pushViewController:col animated:YES];
    }else if([targettype isEqualToString:@"1"])
    {
        MyOrderController *orderCol = [[MyOrderController alloc] init];
        orderCol.hidesBottomBarWhenPushed = YES;
//        [pushCol.navigationController pushViewController:orderCol animated:YES];
    }else if([targettype isEqualToString:@"2"])
    {
        MyCouponsController *couponsCol = [[MyCouponsController alloc] init];
        couponsCol.hidesBottomBarWhenPushed = YES;
//        [pushCol.navigationController pushViewController:couponsCol animated:YES];
    }else if([targettype isEqualToString:@"3"])
    {
        MyFightingController *fightCol = [[MyFightingController alloc] init];
        fightCol.hidesBottomBarWhenPushed = YES;
//        [pushCol.navigationController pushViewController:fightCol animated:YES];
    }else if([targettype isEqualToString:@"5"])
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@",inDic[@"messagename"]]
                                                         message:[NSString stringWithFormat:@"%@",inDic[@"content"]]
                                                        delegate:self
                                               cancelButtonTitle:@"确定"
                                               otherButtonTitles:@"取消",nil];
        [alert show];
        alert.tag= 211;
        _h5Dic = inDic[@"param"];
    }
    [self exampleHandleRunningAPNSWithUserInfo:userInfo];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag == 387) {
        if (buttonIndex == 0) {
             [self openChatWithaConversationId:ConversationId];
        }
    }else if(alertView.tag ==277)
    {
//        MMDrawerController *drawerCol = (MMDrawerController *)self.window.rootViewController;
//        MainController *mainCol = (MainController *)drawerCol.centerViewController;
//        mainCol.isPay = YES;
//        UINavigationController *nav  = (UINavigationController *)mainCol.selectedViewController;
//        NSArray *array = nav.viewControllers;
//        UIViewController *pushCol =  array[array.count-1];
//        [pushCol.navigationController  popToRootViewControllerAnimated:YES];
        
        //创建通知
        NSNotification *notification =[NSNotification notificationWithName:KWeChatPay object:nil userInfo:nil];
        //通过通知中心发送通知
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        
    }else if(alertView.tag == 211)
    {
        if (buttonIndex == 0) {
//            MMDrawerController *drawerCol = (MMDrawerController *)self.window.rootViewController;
//            MainController *mainCol = (MainController *)drawerCol.centerViewController;
//            UINavigationController *nav  = (UINavigationController *)mainCol.selectedViewController;
//            NSArray *array = nav.viewControllers;
//            UIViewController *pushCol =  array[array.count-1];
            HomeH5Controller *col = [[HomeH5Controller alloc] init];
            col.name = _h5Dic[@"title"];
            col.url = _h5Dic[@"url"];
            col.idtype = @"0";
            
            col.hidesBottomBarWhenPushed = YES;
            
//            [pushCol.navigationController pushViewController:col animated:YES];
        
            
        }
    }

}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [UMSocialSnsService handleOpenURL:url];
}


/// iOS8下申请DeviceToken
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
}
#endif


/**
 *  设置DeviceToken
 */
- (void)exampleSetDeviceToken:(NSData *)aDeviceToken
{
//    [[SPUtil sharedInstance] showNotificationInViewController:self.window.rootViewController title:@"设置DeviceToken" subtitle:aDeviceToken.description type:SPMessageNotificationTypeMessage];
    
    [[[YWAPI sharedInstance] getGlobalPushService] setDeviceToken:aDeviceToken];
}

/**
 *  处理启动时APNS消息
 */
- (void)exampleHandleAPNSWithLaunchOptions:(NSDictionary *)aLaunchOptions
{
    [[[YWAPI sharedInstance] getGlobalPushService] handleLaunchOptions:aLaunchOptions completionBlock:^(NSDictionary *aAPS, NSString *aConversationId) {
        /// 打开会话
        [self openChatWithaConversationId:aConversationId];
        
    }];
}

/**
 *  处理运行时APNS消息
 */
- (void)exampleHandleRunningAPNSWithUserInfo:(NSDictionary *)aUserInfo
{
    [[[YWAPI sharedInstance] getGlobalPushService] handlePushUserInfo:aUserInfo completionBlock:^(NSDictionary *aAPS, NSString *aConversationId) {
        if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
            /// 应用从后台划开
            /// 直接打开会话
            [self openChatWithaConversationId:aConversationId];
        } else {
            /// 应用处于前台
            /// 提示用户是否打开会话
            ConversationId = aConversationId;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示有新消息" message:@"确定要打开吗" delegate:self cancelButtonTitle:@"确定"otherButtonTitles:@"取消", nil];
            alertView.tag = 387;
            
            [alertView show];
        }
    }];
}

- (void)openChatWithaConversationId:(NSString *)aConversationId
{
//    YWConversationViewController *conversationController = [[SPKitExample sharedInstance].ywIMKit makeConversationViewControllerWithConversationId:aConversationId];
//    MMDrawerController *drawerCol = (MMDrawerController *)self.window.rootViewController;
//    MainController *mainCol = (MainController *)drawerCol.centerViewController;
//    mainCol.isPay = YES;
//    UINavigationController *nav  = (UINavigationController *)mainCol.selectedViewController;
//    NSArray *array = nav.viewControllers;
//    UIViewController *pushCol =  array[array.count-1];
//    [pushCol.navigationController pushViewController:conversationController animated:YES];
//    [pushCol.navigationController setNavigationBarHidden:NO];
}


#pragma mark ==========全局的东西，借用一下
//处理上传的事件
- (void)handlePublishPictureActionWithPublishPictureArray:(NSArray *)publishPictureArray andWord:(NSString *)word andNightShopID:(NSString *)nightShopId{
    
    self.publishPictureArray = publishPictureArray;
    self.publishWord = word;
    self.publishPictureUrlStringArray = [NSMutableArray array];
    if (_publishPictureArray.count) {
        dispatch_group_t group = dispatch_group_create();
        for (UIImage *image in _publishPictureArray) {
            dispatch_group_enter(group);
            NSData *data = UIImageJPEGRepresentation(image, 0.3);
            //图片保存的路径
            NSString * DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager createDirectoryAtPath:DocumentsPath withIntermediateDirectories:YES attributes:nil error:nil];
            [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:@"/image.png"] contents:data attributes:nil];
            NSString * filePath = [[NSString alloc]initWithFormat:@"%@%@",DocumentsPath,  @"/image.png"];
            //        NSLog(@"图片的完整路径是：%@", filePath);
            
            NSMutableDictionary *user = [[NSUserDefaults standardUserDefaults] objectForKey:kUserBaseInfo];
            NSString *pictureName = [NSString stringWithFormat:@"%ld%@",(long)time,user[@"userid"]];


            pictureName = [pictureName md5Encrypt];

            FSOSSRequest *ossRequest = [[FSOSSRequest alloc] init];
            [ossRequest uploadPictureWithPictureName:pictureName andWithPath:filePath completion:^(id result) {
                if (result) {
                    NSString *urlstr = [result stringByReplacingOccurrencesOfString:@"app/" withString:@""];
                    [self.publishPictureUrlStringArray addObject:urlstr];
                    dispatch_group_leave(group);


                }else
                {
                    dispatch_group_leave(group);

//                    [self hideHUD:@"图片上传失败"];
                    
                }
            }];
        }
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            if (self.publishPictureUrlStringArray.count != self.publishPictureArray.count) {
//                [SVProgressHUD showErrorWithStatus:@"网络慢,发布评论失败"];
                
//                NSLog(@"%d    %d",self.publishPictureUrlStringArray.count,self.publishPictureArray.count);
                
                
            } else {
                
                [self publishAllInfoWithNightShopID:nightShopId];
            }
        });
    } else {
        
        [self publishAllInfoWithNightShopID:nightShopId];
    }
    
}

//当数据存储满时 向服务器提交addWeibo申请
- (void)publishAllInfoWithNightShopID:(NSString *)nightShopId{
    
    NSDictionary *user = [[NSUserDefaults standardUserDefaults] objectForKey:kUserBaseInfo];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (user[@"userID"]&&user[@"token"]) {
        dic = @{@"userID":user[@"userID"],@"sessionToken":user[@"token"]}.mutableCopy;
    }else{
        return;
    }
    
    
    
    
    dic[@"venueID"] = nightShopId;
    if (self.publishWord.length>0) {
        dic[@"commentContent"] = self.publishWord;
    }
    if (self.publishPictureUrlStringArray.count>0) {
        dic[@"pictures"] = [self.publishPictureUrlStringArray componentsJoinedByString:@","];
    }
    
    
    
    [MyDataRequest requestNewURL:@"/venue/comment/create" params:dic completion:^(id operation, NSDictionary *result) {
        NSNumber *n = operation[@"status"];
        if (n.integerValue == 1100) {
            [FSTool pushToLogin];
            
            return;
        }

        if (n.integerValue == 200 ) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"commentSuccess" object:nil];
            [FSTool showToastMessage:@"评论成功" inView:[UIApplication sharedApplication].keyWindow];
        }else{
            [FSTool showToastMessage:@"网络不好，评论失败" inView:[UIApplication sharedApplication].keyWindow];

        }
        
        
    }];
    
    
//    [GZBaseRequest addWeiBoWithUserid:_userid token:_token word:[_publishWord stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] nightshopid:nightShopId andPicURLArray:_publishPictureUrlStringArray AndGrade:self.publishingScore Andcallback:^(id responseObject, NSError *error) {
//        NSNumber *data = [responseObject objectForKey:@"data"];
//        if ([data integerValue] != 1) {
//            [SVProgressHUD showErrorWithStatus:@"网络慢,发布评论失败"];
//        }
//        self.isPublishing = NO;
//        self.publishingScore = @"5";
//    }];
}





@end
