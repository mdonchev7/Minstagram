//
//  LoginSceneLineView.m
//  Minstagram
//
//  Created by Mincho Dzhagalov on 1/14/17.
//  Copyright © 2017 Mincho Dzhagalov. All rights reserved.
//

#import "LoginSceneLineView.h"

@implementation LoginSceneLineView

- (void)drawRect:(CGRect)rect {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    [path moveToPoint:CGPointMake(0.0f, 0.0f)];
    [path addLineToPoint:CGPointMake(screenWidth, 0.0f)];
    
    path.lineWidth = 1;
    [[UIColor lightGrayColor] setStroke];
    
    [path stroke];
}

@end
