//
//  MainController.m
//  动享
//
//  Created by 唐余威 on 15/7/28.
//  Copyright (c) 2015年 唐余威. All rights reserved.
//

#import "MainController.h"
#import "BaseNavigationController.h"

#import "HomeTwoViewController.h"
#import <Masonry.h>
#import "PersonalViewController.h"
#import "FindController.h"
#import "MessageListController.h"
#import "VenueListController.h"
#import "CityModel.h"
#import "ActivityListTwoController.h"
#import "SPersonalViewController.h"
#import "FindController.h"


#define noSelectedColor [UIColor colorWithHexString:@"beb5b1"]
#define SelectedColor [UIColor colorWithHexString:@"f95e00"]


@interface MainController ()

@end

@implementation MainController
{
    NSArray *_name;

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
//    NSLog(@"页面销毁");
    //移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNewMessage object:nil];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMessageAction) name:kNewMessage object:nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self _removeTabBarIems];
    [self _createViewCol];
    [self _createTabBarView];

}

- (void)_createViewCol
{

    NSMutableArray *viewCols = [NSMutableArray arrayWithCapacity:4];
    for (int i = 0; i < 4; i++) {
        UIViewController *col = [[UIViewController alloc] init];
        if (i == 0) {
            col = [[HomeTwoViewController alloc] init];
            
        }else if(i == 1)
        {
            col = [[FindController alloc] init];
        }else if(i == 2)
        {
            col = [[MessageListController alloc] init];
        }else if(i == 3)
        {
            col = [[SPersonalViewController alloc] init];
        }
        BaseNavigationController *nav=[[BaseNavigationController alloc]initWithRootViewController:col];
        [viewCols addObject:nav];
    }
    self.viewControllers = viewCols;
    _backview = [[UIView alloc] initWithFrame:self.view.frame];
    _backview.backgroundColor = [UIColor blackColor];
    _backview.alpha = 0.3;
    _backview.hidden = YES;
    [self.view addSubview:_backview];
    
}


- (void)_removeTabBarIems
{
    NSArray *items = self.tabBar.subviews;
    Class itemsClass = NSClassFromString(@"UITabBarButton");
    
    for (UIView *view in items) {
        if ([view isKindOfClass:[itemsClass class]]) {
            [view removeFromSuperview];
        }
    }
}

- (void)_createTabBarView
{
    _name = @[@"首页",@"发现",@"消息",@"我的"];
    CGFloat width = kScreenWidth / 4;
    _imgArray = [NSMutableArray array];
    _labelArray = [NSMutableArray array];
    for (int i = 0; i < 4; i++) {
        UIView *view =[[UIView alloc] initWithFrame:CGRectMake(i*width, 0, width, self.tabBar.frame.size.height)];
        view.backgroundColor = [UIColor colorWithHexString:@"f4f4f4"];
        [self.tabBar addSubview:view];
        UIView *inView = [UIView new];
        [view addSubview:inView];
        view.tag = 100 +i;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeAction:)];
        [view addGestureRecognizer:tap];
        [inView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(view);
            make.size.mas_equalTo(CGSizeMake(25, 40));
    
        }];
        UIImageView *imageView = [UIImageView new];
        [inView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(inView.mas_top);
            make.left.right.equalTo(inView);
            make.height.mas_equalTo(25);
            
        }];
        imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@2.png",_name[i]]];
        [_imgArray addObject:imageView];
        
        UILabel *label = [UILabel new];
        [inView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(imageView.mas_bottom).offset(5);
            make.left.right.equalTo(inView);
            make.height.mas_equalTo(10);
            
        }];
        label.text = _name[i];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:10];
        label.textColor = noSelectedColor;
        [_labelArray addObject:label];
        
//        if (i==2) {
//            [label removeFromSuperview];
//            [imageView removeFromSuperview];
//            UIImage *storyMenuItemImage = [UIImage imageNamed:@"bg-menuitem.png"];
//            UIImage *storyMenuItemImagePressed = [UIImage imageNamed:@"bg-menuitem-highlighted.png"];
//            AwesomeMenuItem *starMenuItem1 = [[AwesomeMenuItem alloc] initWithImage:storyMenuItemImage
//                                                                   highlightedImage:storyMenuItemImagePressed
//                                                                       ContentImage:[UIImage imageNamed:@"羽毛球.png"]
//                                                            highlightedContentImage:nil];
//            AwesomeMenuItem *starMenuItem2 = [[AwesomeMenuItem alloc] initWithImage:storyMenuItemImage
//                                                                   highlightedImage:storyMenuItemImagePressed
//                                                                       ContentImage:[UIImage imageNamed:@"篮球.png"]
//                                                            highlightedContentImage:nil];
//            AwesomeMenuItem *starMenuItem3 = [[AwesomeMenuItem alloc] initWithImage:storyMenuItemImage
//                                                                   highlightedImage:storyMenuItemImagePressed
//                                                                       ContentImage:[UIImage imageNamed:@"足球.png"]
//                                                            highlightedContentImage:nil];
//            AwesomeMenuItem *starMenuItem4 = [[AwesomeMenuItem alloc] initWithImage:storyMenuItemImage
//                                                                   highlightedImage:storyMenuItemImagePressed
//                                                                       ContentImage:[UIImage imageNamed:@"排球.png"]
//                                                            highlightedContentImage:nil];
//            AwesomeMenuItem *starMenuItem5 = [[AwesomeMenuItem alloc] initWithImage:storyMenuItemImage
//                                                                   highlightedImage:storyMenuItemImagePressed
//                                                                       ContentImage:[UIImage imageNamed:@"乒乓球.png"]
//                                                            highlightedContentImage:nil];
//            
//            NSArray *menuItems = [NSArray arrayWithObjects:starMenuItem1, starMenuItem2, starMenuItem3, starMenuItem4, starMenuItem5,nil];
//            
//            AwesomeMenuItem *startItem = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"初.png"]
//                                                               highlightedImage:[UIImage imageNamed:@"按下.png"]
//                                                                   ContentImage:[UIImage imageNamed:@"初1.png"]
//                                                        highlightedContentImage:[UIImage imageNamed:@"按下1"]];
//            
//            _menu = [[AwesomeMenu alloc] initWithFrame:CGRectMake(100,100, 0, 0) startItem:startItem menuItems:menuItems];
//
////            UIView *menuView = [UIView new];
////            [self.tabBar.superview addSubview:menuView];
////            menuView.backgroundColor = [UIColor clearColor];
////            [menuView mas_makeConstraints:^(MASConstraintMaker *make) {
////                make.left.right.bottom.equalTo(self.tabBar.superview);
////                make.height.equalTo(@(49));
////            }];
//            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth/2-49.0/2, 0, 49, 49)];
//            [self.tabBar addSubview:imageView];
//            imageView.image =[UIImage imageNamed:@"中心按钮.png"];
////            imageView.center =self.tabBar.center;
////            [self.tabBar.superview addSubview:_menu];
////            [_menu mas_makeConstraints:^(MASConstraintMaker *make) {
////                make.center.equalTo(self.tabBar);
////                make.size.mas_equalTo(CGSizeMake(49, 49));
////            }];
//          
//        }
    }
    UIImageView *imgView = _imgArray[0];
    imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@1.png",_name[0]]];
    UILabel *firstLabel = _labelArray[0];
    firstLabel.textColor = SelectedColor;
}

- (void)changeAction:(UITapGestureRecognizer *)tap
{
    UIImageView *backimgView = _imgArray[self.selectedIndex ];
    backimgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@2.png",_name[self.selectedIndex]]];
    UILabel *backlabel = _labelArray[self.selectedIndex ];
    backlabel.textColor = noSelectedColor;//select color
    UIImageView *imgView = _imgArray[tap.view.tag-100];
    imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@1.png",_name[tap.view.tag-100]]];
    UILabel *firstLabel = _labelArray[tap.view.tag-100];
    firstLabel.textColor = SelectedColor;
    self.selectedIndex = tap.view.tag-100;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)awesomeMenu:(AwesomeMenu *)menu didSelectIndex:(NSInteger)idx
{
//    NSLog(@"Select the index : %ld",(long)idx);
//    HomeViewController *homeCol = self.viewControllers[0];
    _backview.hidden = YES;
//    [homeCol pushVenue];

    
}
- (void)awesomeMenuWillAnimateOpen:(AwesomeMenu *)menu
{
     _backview.hidden = NO;
}

- (void)awesomeMenuDidFinishAnimationClose:(AwesomeMenu *)menu
{
    _backview.hidden = YES;
}


- (void)newMessageAction
{
    if (self.selectedIndex == 2) {
        return;
    }
    UIImageView *imgView = _imgArray[2];
    imgView.image = [UIImage imageNamed:@"有新消息.png"];
    
}

@end
