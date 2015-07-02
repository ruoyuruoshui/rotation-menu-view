//
//  LEDrawPathOperation.m
//  LELineDemo
//
//  Created by 陈记权 on 6/25/15.
//  Copyright (c) 2015 陈记权. All rights reserved.
//

#import "LEDrawPathOperation.h"

@interface LEDrawPathOperation()

@property (nonatomic, strong) UIBezierPath *internalPath;

@end

@implementation LEDrawPathOperation

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.internalPath = [UIBezierPath bezierPath];
    }
    return self;
}

- (void)drawInContext:(CGContextRef)context inRect:(CGRect)rect
{
    UIBezierPath *path = [self.internalPath copy];
    
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, self.brush.lineWidth);
    
    CGMutablePathRef newPath = CGPathCreateMutableCopy(path.CGPath);
    CGContextAddPath(context, newPath);
    CGContextSetStrokeColorWithColor(context, self.brush.color.CGColor);
    
    CGContextStrokePath(context);
    
    CFRelease(newPath);
}

- (void)addSubpath:(UIBezierPath *)subpath
{
    if (subpath) {
        [self.internalPath appendPath:subpath];
    }
}

@end
