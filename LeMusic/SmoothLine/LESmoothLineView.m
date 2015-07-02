//
//  LESmoothLineView.m
//  LeLineDemo
//
//  Created by 陈记权 on 6/25/15.
//  Copyright (c) 2015 陈记权. All rights reserved.
//

#import "LESmoothLineView.h"

static UIColor *DefaultBackgroundColor = nil;
static const CGFloat PointMinDistance = 4.0f;
static const CGFloat PointMinDistanceSqiared = PointMinDistance * PointMinDistance;

static CGPoint middle_point(CGPoint p1, CGPoint p2)
{
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}

@interface LESmoothLineView ()

@property (nonatomic, assign) CGPoint currentPoint;
@property (nonatomic, assign) CGPoint previousPoint;
@property (nonatomic, assign) CGPoint previousPreviousPoint;

@property (nonatomic, strong) LEDrawPathOperation *pathOperation;

@end

@implementation LESmoothLineView


+ (void)initialize
{
    DefaultBackgroundColor = [UIColor clearColor];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        // NOTE: do not change the backgroundColor here, so it can be set in IB.
        [self setUpSmoothLineView];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = DefaultBackgroundColor;
        
        [self setUpSmoothLineView];
    }
    
    return self;
}

- (void)setUpSmoothLineView
{
    self.brush = [LEBrush new];
}

- (void)drawRect:(CGRect)rect
{
    // clear rect
    [self.backgroundColor set];
    UIRectFill(rect);
    
    // get the graphics context and draw the path
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextSetShouldAntialias(context, YES);
    CGContextSetAllowsAntialiasing(context, YES);
    CGContextSetFlatness(context, 0.1f);
    
    if (self.pathOperation) {
        [self.pathOperation drawInContext:context inRect:rect];
    }
}

- (void)drawOperationBeganWithCurrentPoint:(CGPoint)curPoint perPoint:(CGPoint)prePoint
{
    self.pathOperation = [[LEDrawPathOperation alloc]init];
    self.pathOperation.brush = [self.brush copy];
    
    // initializes our point records to current location
    self.previousPoint = prePoint;
    self.previousPreviousPoint = prePoint;
    self.currentPoint = curPoint;
    
    //[self drawOperationMoved:touches];
}

- (void)drawOperationMovedWithCurrentPoint:(CGPoint)curPoint perPoint:(CGPoint)prePoint
{
    CGPoint point = curPoint;
    
    // if the finger has moved less than the min dist ...
    CGFloat dx = point.x - self.currentPoint.x;
    CGFloat dy = point.y - self.currentPoint.y;
    CGFloat distance = (dx * dx + dy * dy);
    
    if ((distance > 0) && (distance < PointMinDistanceSqiared)) {
        // ... then ignore this movement
        return;
    }
    
    // update points: previousPrevious -> mid1 -> previous -> mid2 -> current
    self.previousPreviousPoint = self.previousPoint;
    self.previousPoint = prePoint;//[touch previousLocationInView:self];
    self.currentPoint = curPoint;//[touch locationInView:self];
    
    CGPoint mid1 = middle_point(self.previousPoint, self.previousPreviousPoint);
    CGPoint mid2 = middle_point(self.currentPoint, self.previousPoint);
    
    // to represent the finger movement, create a new path segment,
    // a quadratic bezier path from mid1 to mid2, using previous as a control point
    CGMutablePathRef subpath = CGPathCreateMutable();
    CGPathMoveToPoint(subpath, NULL, mid1.x, mid1.y);
    CGPathAddQuadCurveToPoint(subpath, NULL,
                              self.previousPoint.x, self.previousPoint.y,
                              mid2.x, mid2.y);
    
    // compute the rect containing the new segment plus padding for drawn line
    CGRect bounds = CGPathGetBoundingBox(subpath);
    CGRect drawBox = CGRectInset(bounds, -2.0 * self.pathOperation.brush.lineWidth, -2.0 * self.pathOperation.brush.lineWidth);
    
    [self.pathOperation addSubpath:[UIBezierPath bezierPathWithCGPath:subpath]];
    
    CGPathRelease(subpath);
    
    [self setNeedsDisplayInRect:drawBox];
}

static CGPoint prePoint;

- (void)handleGesture:(UIGestureRecognizer *)gesture targetView:(UIView *)targetView
{
    if (![gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
        return;
    }
    
    UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)gesture;
    
    CGPoint currentPoint = [gesture locationInView:self];
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
            
            prePoint = currentPoint;
            [self drawOperationBeganWithCurrentPoint:currentPoint perPoint:prePoint];
            break;
        
        case UIGestureRecognizerStateChanged:
            [self drawOperationMovedWithCurrentPoint:currentPoint perPoint:prePoint];
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            [self drawOperationEnded];
            break;
            
        default:
            break;
    }
    
    prePoint = currentPoint;
}


- (void)drawOperationEnded
{
    [self clear];
}

- (void)clear
{
    self.pathOperation = nil;
    [self setNeedsDisplay];
}

@end
