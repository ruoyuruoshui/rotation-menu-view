//
//  LERotateMenuView.m
//  LERotateMenuView
//
//  Created by 陈记权 on 6/22/15.
//  Copyright (c) 2015 陈记权. All rights reserved.
//

#import "LERotateMenuView.h"
#import "LERotateMenuItem.h"
#import "Math.h"
#import "NSArray+Circular.h"
#import <QuartzCore/QuartzCore.h>

#define kVisibleAngle       (M_PI)

@interface LERotateMenuView ()
{
    BOOL centerSelectedItem;
    
    NSInteger selectedIndex;
    NSMutableArray *menuItems;
    
    NSInteger startPosition;
    
    CGFloat radius;
    
    CGFloat separationAngle;
    
    BOOL isRightMove;
    BOOL isLeftMove;
    BOOL isSingleTap;
    BOOL hasRespondToGesture;
    NSDate *startTime;
}

@end

@implementation LERotateMenuView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self defaultInit];
        [self setFrame:frame];
    }
    return self;
}

- (void)defaultInit
{
    centerSelectedItem = YES;
    
    menuItems = [[NSMutableArray alloc]init];
    self.visibleCount = 5;
    self.multipleTouchEnabled = YES;
    self.userInteractionEnabled = YES;
    self.autoresizesSubviews = YES;
    
    self.layer.position = CGPointMake(CGRectGetWidth(self.frame) / 2.0f, CGRectGetHeight(self.frame) / 2.0f);
    
    self.clipsToBounds = YES;
    
    selectedIndex = -1;
    separationAngle = 0.0f;
}

- (void)setAntialiasing:(BOOL)flag
{
    CGContextSetAllowsAntialiasing(UIGraphicsGetCurrentContext(), flag);
    CGContextSetShouldAntialias(UIGraphicsGetCurrentContext(), flag);
}

- (void)addItem:(LERotateMenuItem *)item
{
    if (!item) {
        return;
    }
    
    if (selectedIndex == -1) {
        selectedIndex = 0;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.layer insertSublayer:item.layer atIndex:(unsigned)[menuItems count]];
        
        [item.layer setPosition:CGPointMake(CGRectGetWidth(self.frame) / 2.0f, CGRectGetHeight(self.frame) / 2.0f)];
        item.angle = M_PI;
        item.hidden = YES;
        [menuItems addObject:item];
        
        [self refreshItemsPositionWithAnimationed:YES];
    });
}

- (void)removeItem:(LERotateMenuItem *)item
{
    if (!item) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [item.layer removeFromSuperlayer];
        
        [menuItems removeObject:item];
        
        [self refreshItemsPositionWithAnimationed:NO];
    });
}

- (LERotateMenuItem *)getItemAtIndex:(NSInteger)index
{
    if (!menuItems || menuItems.count < index + 1) {
        return nil;
    }
    
    return [menuItems objectAtIndex:index];
}

- (NSArray *)getItems
{
    return menuItems;
}

- (void)refreshItemsPositionWithAnimationed:(BOOL)animtion
{
    if (!menuItems || menuItems.count == 0) {
        return;
    }
    
    if ( menuItems.count < 5) {
        return;
    }
    
    NSInteger numberOfItems = self.visibleCount;
    UIView *itemView = (UIView *)[menuItems objectAtIndex:0];
    
    separationAngle = kVisibleAngle / numberOfItems;
    
    radius = CGRectGetWidth(itemView.frame) / tan(separationAngle / 2.0f) * 1.2;
    
    if (animtion) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationBeginsFromCurrentState:YES];
    }
    
    CGFloat increaseAngle = 0.0f , decreaseAngle =  0.0f;
    
    NSInteger pLeft = 0;
    NSInteger pRight = 0;
    
    for (NSInteger i = 0; i <= menuItems.count / 2; i ++) {
        LERotateMenuItem *leftItem = [menuItems circularObjectAtIndex:pLeft];
        leftItem.angle = decreaseAngle;
        
        if (i <= numberOfItems / 2) {
            [leftItem.layer setAnchorPoint:CGPointMake(0.5, 0.5)];
            [leftItem.layer setAnchorPointZ:0.0f];
            [self menuItem:leftItem originAngle:0.0f animatonDuration:0.5];
            leftItem.hidden = NO;
        } else {
            leftItem.hidden = YES;
        }
        
        
        if (pLeft != pRight) {
            LERotateMenuItem *rightItem = [menuItems circularObjectAtIndex:pRight];
            if (i <= numberOfItems / 2){
                rightItem.angle = increaseAngle;
                [rightItem.layer setAnchorPoint:CGPointMake(0.5, 0.5)];
                [rightItem.layer setAnchorPointZ:0.0f];
                [self menuItem:rightItem originAngle:0.0f animatonDuration:0.5];
                rightItem.hidden = NO;
                startPosition = pLeft;
            } else {
                rightItem.hidden = YES;
            }
        }
        
        pLeft --;
        pRight ++;
        increaseAngle += separationAngle;
        decreaseAngle  -= separationAngle;
    }
    
    if (animtion) {
        [UIView commitAnimations];
    }
}

static NSInteger originOffset = 0;

- (void)handlePanGesture:(UIGestureRecognizer *)gesture targetView:(UIView *)view
{
    if (![gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
        return;
    }
    
    isSingleTap = NO;
    
    UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)gesture;
    
    CGPoint translation = [panGesture translationInView:view];
    
    if (atan(fabs(translation.y) / fabs(translation.x) > M_PI / 12) && !hasRespondToGesture) {
        return;
    }
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            originOffset = 0;
            hasRespondToGesture = NO;
        }
            break;
        
        case UIGestureRecognizerStateChanged:
        {
            hasRespondToGesture = YES;
            CGFloat offset = atan((translation.x - originOffset) / radius);
            originOffset = translation.x;
            if (offset > 0) {
                isRightMove = YES;
                isLeftMove = NO;
            } else {
                isRightMove = NO;
                isLeftMove = YES;
            }
            
            [self moveVisibleItemsWithOffset:offset];
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            if (selectedIndex != self.visibleCount / 2 + startPosition) {
                 selectedIndex = self.visibleCount / 2 + startPosition;
            } else {
                if (isRightMove) {
                    selectedIndex -= 1;
                } else {
                    selectedIndex += 1;
                }
            }
            LERotateMenuItem *selectedItem = [menuItems circularObjectAtIndex:selectedIndex];
            [self setSelectedItemAndCenter:selectedItem];
        }
            break;
        default:
            break;
    }
    
}

- (void)moveVisibleItemsWithOffset:(CGFloat)angleOffset
{
    if (fabs(angleOffset) == 0) {
        return;
    }
    
    NSInteger index = startPosition;
    for (NSInteger i = 0; i < self.visibleCount; i ++) {
        LERotateMenuItem *item = [menuItems circularObjectAtIndex:index];
        CGFloat originAngle = item.angle;
        item.angle += angleOffset;
      
        [self menuItem:item originAngle:originAngle animatonDuration:0.5];
        
       [UIView animateWithDuration:0 delay:0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState animations:^{
           if (isLeftMove) {
               if (item.angle <= -M_PI / 2.0f) {
                   item.hidden = YES;
                   
                   NSInteger willAppearIndex = startPosition + self.visibleCount;
                   LERotateMenuItem *willAppearItem = [menuItems circularObjectAtIndex:willAppearIndex];
                   willAppearItem.angle = M_PI / 2.0 + (item.angle + M_PI / 2.0f);
                   willAppearItem.hidden = NO;

                   [self menuItem:willAppearItem originAngle:M_PI / 2.0 animatonDuration:0.5];
                   startPosition = startPosition + 1;
               }
           } else if(isRightMove) {
               if (item.angle >= M_PI / 2.0f) {
                   item.hidden = YES;
                   
                   NSInteger willAppearIndex = startPosition - 1;
                   LERotateMenuItem *willAppearItem = [menuItems circularObjectAtIndex:willAppearIndex];
                   willAppearItem.angle = -M_PI / 2.0 + (item.angle - M_PI / 2.0f);
                   willAppearItem.hidden = NO;
                   [self menuItem:willAppearItem originAngle:- M_PI / 2.0 animatonDuration:0.5];
                   startPosition = startPosition - 1;
               }
           }
        } completion:^(BOOL finished) {
            
        }];
        
        index ++;
    }
}

#define kScaleAngle (M_PI / 12.0)

- (CGFloat)getScaleWithOffsetToCenter:(CGFloat)offset
{
    CGFloat width = 35.0f;
    CGFloat scale = ((width / tan(kScaleAngle) - fabs(offset) / 1.8) * tan(kScaleAngle)) / width;
    return scale;
}

#define kScaleAnimationKey @"scale.animaton"

- (void)menuItem:(LERotateMenuItem *)item originAngle:(CGFloat)originAngle animatonDuration:(CGFloat)duration
{
    CGFloat scale = [self getScaleWithOffsetToCenter:radius * sin(item.angle / 2)];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    
    CGFloat originScale = [self getScaleWithOffsetToCenter:radius * sin(originAngle / 2)];
    
    CATransform3D scaleTransform = CATransform3DMakeScale(originScale, originScale, 1.0);
    NSValue *value = [NSValue valueWithCATransform3D:scaleTransform];
    [animation setFromValue:value];
    
    scaleTransform = CATransform3DMakeScale(scale, scale, 1.0f);
    value = [NSValue valueWithCATransform3D:scaleTransform];
    [animation setToValue:value];
    
    [animation setDuration:duration];
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    [item.layer addAnimation:animation forKey:kScaleAnimationKey];
    
    CABasicAnimation *disappear = [CABasicAnimation animationWithKeyPath:@"position"];
    disappear.duration = duration;
    disappear.fromValue = [NSValue valueWithCGPoint:CGPointMake(CGRectGetWidth(self.frame) / 2.0f + radius * sin(originAngle / 2), CGRectGetHeight(self.frame) / 2.0f)];
    disappear.toValue = [NSValue valueWithCGPoint:CGPointMake(CGRectGetWidth(self.frame) / 2.0f + radius * sin(item.angle / 2), CGRectGetHeight(self.frame) / 2.0f)];
    disappear.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    disappear.fillMode = kCAFillModeForwards;
    disappear.removedOnCompletion = NO;
    [item.layer addAnimation:disappear forKey:@"positionAnimation"];
    
    item.alpha = cos(item.angle);
}

- (void)setSelectedItemAndCenter:(LERotateMenuItem *)item
{
    if (fabs(item.angle) < kVisibleAngle / 2.0f) {
        
        if (item.angle < 0) {
            [self moveVisibleItemsWithOffset:-item.angle];
        } else {
            [self moveVisibleItemsWithOffset:-item.angle];
        }
        
        item.angle = 0;
    }
}

- (LERotateMenuItem *)findItemOnScreen:(CALayer *)targetLayer
{
    LERotateMenuItem *foundItem = nil;
    @try {
        for (NSInteger i; i < menuItems.count; i ++) {
            LERotateMenuItem *item = [menuItems circularObjectAtIndex:i];
            for (UIView *subView in item.subviews) {
                if ([subView.layer isEqual:targetLayer]) {
                    foundItem = item;
                    break;
                }
                
                for (UIView *subSubView in subView.subviews) {
                    if ([subSubView.layer isEqual:targetLayer]) {
                        foundItem = item;
                        break;
                    }
                }
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    
    return foundItem;
}


@end
