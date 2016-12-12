//
//  LineView.m
//  Minstagram
//
//  Created by Mincho Dzhagalov on 11/21/16.
//  Copyright © 2016 Mincho Dzhagalov. All rights reserved.
//

#import "LineView.h"

@implementation LineView

- (void)drawRect:(CGRect)rect {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(10.f, 0.0f)];
    [path addLineToPoint:CGPointMake(screenWidth - 28.0f, 0.0f)];
    path.lineWidth = 1;
    [[UIColor lightGrayColor] setStroke];
    [path stroke];
}

@end
