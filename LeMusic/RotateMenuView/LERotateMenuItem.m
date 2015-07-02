//
//  LERotateMenuItem.m
//  LERotateMenuView
//
//  Created by 陈记权 on 6/22/15.
//  Copyright (c) 2015 陈记权. All rights reserved.
//

#import "LERotateMenuItem.h"

@implementation LERotateMenuItem

- (instancetype)init
{
    self = [super init];
    if (self) {
       [self initSubviews]; 
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubviews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initSubviews];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(context, YES);
}

#define kPadding 5.0f
- (void)initSubviews
{
    self.clipsToBounds = YES;
    self.autoresizesSubviews = YES;
    
    self.imageView = [[UIImageView alloc]initWithFrame:self.bounds];
    self.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.imageView];
    
    [self.imageView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    self.imageView.layer.cornerRadius = CGRectGetWidth(self.frame) / 2.0f;
    self.imageView.layer.masksToBounds = YES;
}


@end
