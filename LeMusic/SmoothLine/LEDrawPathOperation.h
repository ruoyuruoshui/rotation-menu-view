//
//  LeDrawPathOperation.h
//  LeLineDemo
//
//  Created by 陈记权 on 6/25/15.
//  Copyright (c) 2015 陈记权. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEBrush.h"

@interface LEDrawPathOperation : NSObject

@property (nonatomic, copy) LEBrush *brush;

- (void)addSubpath:(UIBezierPath *)subpath;

- (void)drawInContext:(CGContextRef)context inRect:(CGRect)rect;

@end
