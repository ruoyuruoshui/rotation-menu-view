//
//  NSArray+Circular.m
//  LERotateMenuView
//
//  Created by 陈记权 on 6/22/15.
//  Copyright (c) 2015 陈记权. All rights reserved.
//

#import "NSArray+Circular.h"

@implementation NSArray (Circular)

- (id)circularObjectAtIndex:(NSInteger)index
{
    while (index < 0) {
        index += [self count];
    }
    
    NSInteger realIndex = index % self.count;
    
    return [self objectAtIndex:realIndex];
}

- (id)circularPreviousObject:(NSObject *)object
{
    NSUInteger index = [self indexOfObject:object];
    
    if (index != NSNotFound) {
        return  [self circularObjectAtIndex:index - 1];
    }
    return nil;
}

- (id)circularNextObject:(NSObject *)object
{
    NSUInteger index = [self indexOfObject:object];
    
    if (index != NSNotFound) {
        return  [self circularObjectAtIndex:index + 1];
    }
    
    return nil;
}

@end
