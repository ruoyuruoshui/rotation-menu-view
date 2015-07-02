//
//  NSArray+Circular.h
//  LERotateMenuView
//
//  Created by 陈记权 on 6/22/15.
//  Copyright (c) 2015 陈记权. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Circular)

- (id)circularObjectAtIndex:(NSInteger)index;

- (id)circularPreviousObject:(NSObject *)object;

- (id)circularNextObject:(NSObject *)object;

@end
