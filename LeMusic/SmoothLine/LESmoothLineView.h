//
//  LESmoothLineView.h
//  LeLineDemo
//
//  Created by 陈记权 on 6/25/15.
//  Copyright (c) 2015 陈记权. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LEDrawPathOperation.h"

@interface LESmoothLineView : UIView

@property (nonatomic, strong) LEBrush *brush;

- (void)handleGesture:(UIGestureRecognizer *)gesture targetView:(UIView *)targetView;

@end
