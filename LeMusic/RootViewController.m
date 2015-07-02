//
//  RootViewController.m
//  LeMusic
//
//  Created by 陈记权 on 6/24/15.
//  Copyright (c) 2015 陈记权. All rights reserved.
//

#import "RootViewController.h"
#import "LERotateMenuItem.h"
#import "LERotateMenuView.h"
#import "LESmoothLineView.h"

@interface RootViewController ()

@property (nonatomic, strong) LESmoothLineView *smoothView;
@property (nonatomic, strong) LERotateMenuView *menuView;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    [self setNavigationBar];
    
    [self initMenuView];
    
    [self addPanGestureToView];
    
    [self addTouchTrackerView];
}

- (void)setNavigationBar
{
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 20)];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:24]];
    titleLabel.text = @"乐视动听";
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:16 / 255.0f green:16 / 255.0f blue:16 / 255.0f alpha:1.0f]];
}

- (void)initMenuView
{
    _menuView = [[LERotateMenuView alloc]init];
    [self.view addSubview:_menuView];
    _menuView.backgroundColor = [UIColor colorWithRed:43 / 255.0f green:47 / 255.0f blue:59 / 255.0f alpha:1.0f];
    __weak __typeof(&* self)weakSelf = self;
    
    [_menuView makeConstraints:^(MASConstraintMaker *make) {
        UIView *topView = (UIView *)[weakSelf topLayoutGuide];
        make.top.equalTo(topView.bottom);
        make.left.and.right.equalTo(weakSelf.view);
        make.height.equalTo(90.0f);
    }];
    
    [self menuViewAddSubviews];
}

- (void)addTouchTrackerView
{
    self.smoothView = [[LESmoothLineView alloc]init];
    self.smoothView.userInteractionEnabled = NO;
    self.smoothView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.smoothView];
    
    [self.view bringSubviewToFront:self.smoothView];
    
    __weak __typeof(&* self)weakSelf = self;
    [_smoothView makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(weakSelf.menuView.bottom);
        make.left.bottom.and.right.equalTo(weakSelf.view);
    }];
}

- (void)addPanGestureToView
{
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]init];
    [panGesture addTarget:self action:@selector(panAction:)];
    [self.view addGestureRecognizer:panGesture];
}

- (void)panAction:(UIPanGestureRecognizer *)pan
{
    [_menuView handlePanGesture:pan targetView:self.view];
    
    [self.smoothView handleGesture:pan targetView:self.view];
}

- (void)menuViewAddSubviews
{
    NSArray *iconNames = [NSArray arrayWithObjects:@"icon_book", @"icon_funny", @"icon_js", @"icon_music", @"icon_news", @"icon_video", nil];
    for (NSInteger i = 0; i < iconNames.count; i ++) {
        LERotateMenuItem *item = [[LERotateMenuItem alloc]initWithFrame:CGRectMake(0, 0, 70, 70)];
        item.imageView.image = [UIImage imageNamed:[iconNames objectAtIndex:i]];
        [_menuView addItem:item];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self hideStatus:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self hideStatus:NO];
}

- (void)hideStatus:(BOOL)hide
{
    UIApplication *application = [UIApplication sharedApplication];
    application.statusBarHidden = hide;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
