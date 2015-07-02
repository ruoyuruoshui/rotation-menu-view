//
//  LEBrush.m
//  LeLineDemo
//
//  Created by 陈记权 on 6/25/15.
//  Copyright (c) 2015 陈记权. All rights reserved.
//

#import "LEBrush.h"

@implementation LEBrush

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.lineWidth = 12.0;
        self.color = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    LEBrush *newBrush = [[[self class] allocWithZone:zone] init];
    newBrush.color = self.color;
    newBrush.lineWidth = self.lineWidth;
    
    return newBrush;
}

@end
