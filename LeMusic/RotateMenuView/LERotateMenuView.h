//
//  LERotateMenuView.h
//  LERotateMenuView
//
//  Created by 陈记权 on 6/22/15.
//  Copyright (c) 2015 陈记权. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LERotateMenuView;
@class LERotateMenuItem;

@protocol LERotateMenuViewProtocol <NSObject>


@required

- (void)rorateMenuView:(LERotateMenuView *)menuView itenSelected:(LERotateMenuItem *)item;

@end


@interface LERotateMenuView : UIView

@property (nonatomic, strong) NSArray *angleGradient;
@property (nonatomic, assign) NSInteger visibleCount;

@property (nonatomic, assign) id <LERotateMenuViewProtocol>delegate;

- (void)setSelectedItemAndCenter:(LERotateMenuItem *)item;

- (void)addItem:(LERotateMenuItem *)item;

- (void)removeItem:(LERotateMenuItem *)item;

- (LERotateMenuItem *)getItemAtIndex:(NSInteger)index;

- (NSArray *)getItems;

- (void)handlePanGesture:(UIGestureRecognizer *)gesture targetView:(UIView *)view;

@end
